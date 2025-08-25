import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/star_field.dart';
import '../models/tarot_card.dart';
import 'results_screen.dart';
import '../services/tarot_service.dart';

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

  List<TarotCardModel> fetchedCards = [];
  final TarotService _tarotService = TarotService();
  String? errorMessage;

  @override
  void initState() {
    super.initState();

    fastSpin = AnimationController(vsync: this, duration: const Duration(seconds: 2));
    slowSpin = AnimationController(vsync: this, duration: const Duration(seconds: 3));

    totalAngle = Tween<double>(begin: 0, end: 5 * 2 * pi).animate(
      CurvedAnimation(parent: fastSpin, curve: Curves.easeOut),
    );

    _startSpinningAndFetchCards();
  }

  Future<void> _startSpinningAndFetchCards() async {
    await fastSpin.forward();

    totalAngle = Tween<double>(
      begin: totalAngle.value,
      end: totalAngle.value + (2 * pi + pi),
    ).animate(CurvedAnimation(parent: slowSpin, curve: Curves.easeOut));

    final slowSpinFuture = slowSpin.forward();

    try {
      final fetchedMaps = await _tarotService.getShuffledCards();
      final fetchedModels = fetchedMaps.map((map) {
        return TarotCardModel(
          id: -1,
          name: map['name']!,
          image: map['img']!,
          meanings: {'general': map['meaning']!},
        );
      }).toList();

      setState(() {
        fetchedCards = fetchedModels;
      });

      await slowSpinFuture;

      if (mounted) {
        setState(() {
          isSpinning = false;
          showCards = true;
        });

        await Future.delayed(const Duration(milliseconds: 1500));
        if (mounted) {
          setState(() {
            showResultButton = true;
          });
        }
      }
    } catch (e) {
      await slowSpinFuture;

      if (mounted) {
        setState(() {
          isSpinning = false;
          errorMessage = 'Không thể lấy lá bài: $e';
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
            child: Image.network(
              'https://images.unsplash.com/photo-1534796636912-3b95b3ab5986?q=80&w=1471&auto=format&fit=crop',
              fit: BoxFit.cover,
            ),
          ),
          const StarField(),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.45)),
          ),

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
          if (showCards && !isSpinning) _buildCardsDisplay(),
          if (errorMessage != null) _buildErrorDisplay(),
        ],
      ),
    );
  }

  Widget _buildSpinningDeck() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const _LoadingIndicator(),
        const SizedBox(height: 40),
        Center(
          child: SizedBox(
            width: 250,
            height: 400,
            child: AnimatedBuilder(
              animation: totalAngle,
              builder: (context, _) {
                final angle = totalAngle.value;
                final transform = Matrix4.identity()
                  ..setEntry(3, 2, 0.0015)
                  ..rotateY(angle);
                return Transform(
                  transform: transform,
                  alignment: Alignment.center,
                  child: const _DeckBox(),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCardsDisplay() {
    return Column(
      children: [
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Text(
              'Lá bài của bạn đã được chọn',
              style: GoogleFonts.cinzelDecorative(
                fontSize: 24,
                color: const Color(0xFFFFD700),
              ),
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 650),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 280,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: fetchedCards.asMap().entries.map((entry) {
                        final index = entry.key;
                        final card = entry.value;
                        return _AnimatedCard(
                          card: card,
                          delay: Duration(milliseconds: index * 300),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 40),
                  AnimatedOpacity(
                    opacity: showResultButton ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 800),
                    child: AnimatedSlide(
                      offset: showResultButton ? Offset.zero : const Offset(0, 0.5),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeOutBack,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFD700),
                          foregroundColor: Colors.black,
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          elevation: 12,
                          shadowColor: const Color(0x80FFD700),
                        ),
                        onPressed: showResultButton ? () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ResultsScreen(
                                selected: fetchedCards,
                                topics: widget.topics,
                                name: widget.name,
                                birthDate: widget.birthDate,
                                gender: widget.gender,
                              ),
                            ),
                          );
                        } : null,
                        child: const Text(
                          'Xem Kết Quả',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorDisplay() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Card(
          color: const Color(0xB0000000),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(color: Colors.redAccent.withOpacity(0.3)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.redAccent,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'Đã xảy ra lỗi',
                  style: GoogleFonts.cinzelDecorative(
                    fontSize: 22,
                    color: Colors.redAccent,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  errorMessage!,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD700),
                    foregroundColor: Colors.black,
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Quay lại'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Widget cho bộ bài đang xoay
class _DeckBox extends StatelessWidget {
  const _DeckBox();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: List.generate(20, (i) {
        return Positioned(
          top: 25,
          left: 25,
          child: Container(
            width: 200,
            height: 350,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x88FFD700),
                  blurRadius: 20,
                )
              ],
              image: const DecorationImage(
                image: NetworkImage('https://i.imgur.com/JQ9p7xD.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      }),
    );
  }
}

// Widget cho lá bài với animation xuất hiện
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

class _AnimatedCardState extends State<_AnimatedCard>
    with SingleTickerProviderStateMixin {
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

    _scaleAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6),
    ));

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
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Container(
              width: 160,
              height: 260,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.network(
                        widget.card.image,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[800],
                            child: const Icon(
                              Icons.image_not_supported,
                              color: Colors.white54,
                              size: 48,
                            ),
                          );
                        },
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withOpacity(0.8),
                              Colors.transparent,
                            ],
                          ),
                        ),
                        child: Text(
                          widget.card.name,
                          style: GoogleFonts.cinzelDecorative(
                            fontSize: 14,
                            color: const Color(0xFFFFD700),
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Widget hiển thị loading với text thay đổi
class _LoadingIndicator extends StatefulWidget {
  const _LoadingIndicator();

  @override
  State<_LoadingIndicator> createState() => _LoadingIndicatorState();
}

class _LoadingIndicatorState extends State<_LoadingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _textController;
  final List<String> _loadingTexts = [
    'Kết nối với vũ trụ...',
    'Lắng nghe tiếng thầm của các vì sao...',
    'Giải mã thông điệp từ thần linh...',
    'Chuẩn bị lá bài cho bạn...',
  ];
  int _currentTextIndex = 0;

  @override
  void initState() {
    super.initState();
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _textController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted) {
          setState(() {
            _currentTextIndex = (_currentTextIndex + 1) % _loadingTexts.length;
          });
          _textController.reset();
          _textController.forward();
        }
      }
    });

    _textController.forward();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _textController,
      child: Text(
        _loadingTexts[_currentTextIndex],
        style: GoogleFonts.cinzelDecorative(
          fontSize: 18,
          color: const Color(0xFFFFD700),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}