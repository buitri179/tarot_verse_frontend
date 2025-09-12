import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/tarot_response.dart';
import '../widgets/star_field.dart';
import '../models/tarot_card.dart';
import 'package:go_router/go_router.dart';
import '../services/tarot_service.dart';
import '../services/tarot_deck_service.dart';
import '../config.dart';
import '../data/cosmic_message.dart'; // Đã thêm import

class DeckScreen extends StatefulWidget {
  final List<String> topics;
  final String name;
  final DateTime birthDate;
  final String gender;

  const DeckScreen({
    super.key,
    required this.topics,
    required this.name,
    required this.birthDate,
    required this.gender,
  });

  @override
  State<DeckScreen> createState() => _DeckScreenState();
}

class _DeckScreenState extends State<DeckScreen> with TickerProviderStateMixin {
  late final AnimationController fastSpin;
  late final AnimationController slowSpin;
  late Animation<double> totalAngle;

  bool isSpinning = true;
  bool showCards = false;
  bool showResultButton = false;

  List<TarotCardModel> _drawnCards = [];
  TarotResponse? _tarotResponse;
  final TarotService _tarotService = TarotService();
  final TarotDeckService _deckService = TarotDeckService();
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fastSpin = AnimationController(vsync: this, duration: const Duration(seconds: 2));
    slowSpin = AnimationController(vsync: this, duration: const Duration(seconds: 3));
    totalAngle = Tween<double>(begin: 0, end: 5 * 2 * pi).animate(
      CurvedAnimation(parent: fastSpin, curve: Curves.easeOut),
    );
    _fetchRandomCardsThenAskAI();
  }

  Future<void> _fetchRandomCardsThenAskAI() async {
    await fastSpin.forward();
    totalAngle = Tween<double>(
      begin: totalAngle.value,
      end: totalAngle.value + (2 * pi + pi),
    ).animate(CurvedAnimation(parent: slowSpin, curve: Curves.easeOut));
    final slowSpinFuture = slowSpin.forward();

    try {
      final cards = await _deckService.fetchRandomCards();
      if (!mounted) return;

      setState(() {
        _drawnCards = cards;
        showCards = true;
      });

      final response = await _tarotService.askTarot(
        name: widget.name,
        birthDate: DateFormat('yyyy-MM-dd').format(widget.birthDate),
        gender: widget.gender,
        topic: widget.topics.join(', '),
        cards: cards.map((c) => c.name).toList(),
      );

      if (mounted) {
        setState(() => _tarotResponse = response);
      }

      await slowSpinFuture;
      if (!mounted) return;

      setState(() {
        isSpinning = false;
      });

      await Future.delayed(const Duration(milliseconds: 1200));
      if (mounted) {
        setState(() {
          showResultButton = true;
        });
      }
    } catch (e) {
      await slowSpinFuture;
      if (mounted) {
        setState(() {
          isSpinning = false;
          errorMessage = 'Không thể lấy kết quả: $e';
        });
      }
    }
  }

  @override
  void dispose() {
    fastSpin.dispose();
    slowSpin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/back_ground.jpg', fit: BoxFit.cover),
          ),
          const StarField(),
          Positioned.fill(child: Container(color: Colors.black.withOpacity(0.45))),
          Positioned(
            top: 24,
            left: 12,
            child: SafeArea(
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () => Navigator.pop(context),
                color: const Color(0xFFFFD700),
              ),
            ),
          ),
          if (isSpinning) _buildSpinningDeck(),
          if (showCards && !isSpinning && _drawnCards.isNotEmpty) _buildCardsDisplay(),
          if (errorMessage != null) _buildErrorDisplay(),
        ],
      ),
    );
  }

  Widget _buildSpinningDeck() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CosmicLoadingIndicator(), // Đã thay thế
        const SizedBox(height: 40),
        Center(
          child: SizedBox(
            width: 250,
            height: 400,
            child: AnimatedBuilder(
              animation: totalAngle,
              builder: (context, _) {
                final angle = totalAngle.value;
                const deckDepth = 78 * 0.8;
                return Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.0015)
                    ..multiply(Matrix4.translationValues(0.0, 0.0, -deckDepth / 2))
                    ..rotateY(angle)
                    ..multiply(Matrix4.translationValues(0.0, 0.0, deckDepth / 2)),
                  child: const _DeckBox(),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorDisplay() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 60),
          const SizedBox(height: 20),
          Text(
            errorMessage ?? 'Đã xảy ra lỗi không xác định.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              setState(() {
                errorMessage = null;
                isSpinning = true;
              });
              _fetchRandomCardsThenAskAI();
            },
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  Widget _buildCardsDisplay() {
    if (_drawnCards.isEmpty) return const SizedBox.shrink();
    final drawnCards = _drawnCards;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Các lá bài đã được rút cho bạn',
          style: GoogleFonts.cinzelDecorative(fontSize: 22, color: const Color(0xFFFFD700)),
        ),
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(drawnCards.length, (index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: _AnimatedCard(
                card: drawnCards[index],
                delay: Duration(milliseconds: 300 * index),
              ),
            );
          }),
        ),
        const SizedBox(height: 40),
        if (showResultButton)
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD700),
              foregroundColor: Colors.black,
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
              elevation: 10,
              shadowColor: const Color(0x80FFD700),
            ),
            onPressed: _goToResults,
            child: const Text(
              'Xem Diễn Giải Chi Tiết',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
      ],
    );
  }

  void _goToResults() {
    if (_drawnCards.isEmpty) return;
    context.go(
      '/results',
      extra: {
        'selectedCards': _drawnCards,
        'topics': widget.topics,
        'name': widget.name,
        'birthDate': widget.birthDate,
        'gender': widget.gender,
      },
    );
  }
}

class _AnimatedCard extends StatefulWidget {
  final TarotCardModel card;
  final Duration delay;

  const _AnimatedCard({
    required this.card,
    required this.delay,
  });

  @override
  State<_AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<_AnimatedCard> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6)),
    );

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Image.network(
              '${baseUrl}/${widget.card.imageUrl}',
              width: 100,
              height: 180,
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }
}

class _DeckBox extends StatelessWidget {
  const _DeckBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Image.asset(
        'assets/images/back_card.png',
        width: 100,
        height: 180,
        fit: BoxFit.cover,
      ),
    );
  }
}

// Widget loading mới có hiệu ứng chuyển đổi thông điệp
class CosmicLoadingIndicator extends StatefulWidget {
  const CosmicLoadingIndicator({super.key});

  @override
  State<CosmicLoadingIndicator> createState() => _CosmicLoadingIndicatorState();
}

class _CosmicLoadingIndicatorState extends State<CosmicLoadingIndicator> {
  int _messageIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startMessageCycle();
  }

  void _startMessageCycle() {
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _messageIndex = (_messageIndex + 1) % cosmicMessages.length;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 50,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 800),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, -0.5),
                    end: const Offset(0, 0),
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: Text(
              cosmicMessages[_messageIndex],
              key: ValueKey<int>(_messageIndex),
              textAlign: TextAlign.center,
              style: GoogleFonts.cinzel(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                color: const Color(0xFFFFD700).withOpacity(0.9),
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.5),
                    offset: const Offset(1, 1),
                    blurRadius: 2,
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}