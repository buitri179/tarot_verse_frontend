import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/tarot_response.dart';
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

  // Thay thế fetchedCards bằng tarotResponse
  TarotResponse? _tarotResponse;
  final TarotService _tarotService = TarotService();
  String? errorMessage;

  @override
  void initState() {
    super.initState();

    fastSpin =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    slowSpin =
        AnimationController(vsync: this, duration: const Duration(seconds: 3));

    totalAngle = Tween<double>(begin: 0, end: 5 * 2 * pi).animate(
      CurvedAnimation(parent: fastSpin, curve: Curves.easeOut),
    );

    // Đổi tên hàm để phản ánh đúng chức năng mới
    _fetchReadingAndShowCards();
  }

  // Hàm mới: Gọi API để lấy cả bài và diễn giải
  Future<void> _fetchReadingAndShowCards() async {
    await fastSpin.forward();

    totalAngle = Tween<double>(
      begin: totalAngle.value,
      end: totalAngle.value + (2 * pi + pi),
    ).animate(CurvedAnimation(parent: slowSpin, curve: Curves.easeOut));

    final slowSpinFuture = slowSpin.forward();

    try {
      // Gọi API để lấy kết quả hoàn chỉnh
      final response = await _tarotService.askTarot(
        name: widget.name,
        birthDate: DateFormat('yyyy-MM-dd').format(widget.birthDate),
        gender: widget.gender,
        topic: widget.topics.join(', '),
      );

      if (mounted) {
        setState(() {
          _tarotResponse = response;
        });
      }

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
            child: Image.asset(
              'assets/images/back_ground.jpg',
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
          // Sửa đổi để sử dụng _tarotResponse
          if (showCards && !isSpinning && _tarotResponse != null)
            _buildCardsDisplay(),
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
                const deckDepth = 78 * 0.8; // tổng độ dày bộ bài

                return Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.0015)
                    ..multiply(
                        Matrix4.translationValues(0.0, 0.0, -deckDepth / 2))
                    ..rotateY(angle)
                    ..multiply(
                        Matrix4.translationValues(0.0, 0.0, deckDepth / 2)),
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
              _fetchReadingAndShowCards();
            },
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  Widget _buildCardsDisplay() {
    if (_tarotResponse == null) return const SizedBox.shrink();

    final drawnCards = _tarotResponse!.drawnCards;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Các lá bài đã được rút cho bạn',
          style: GoogleFonts.cinzelDecorative(
            fontSize: 22,
            color: const Color(0xFFFFD700),
          ),
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
    if (_tarotResponse == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ResultsScreen(
          selectedCards: _tarotResponse!.drawnCards,
          topics: widget.topics,
          name: widget.name,
          birthDate: widget.birthDate,
          gender: widget.gender,
        ),
      ),
    );
  }
}

class _DeckSide extends StatelessWidget {
  final double width;
  final double height;

  const _DeckSide({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: const BoxDecoration(
        color: Color(0xFF4a2e19), // Màu nâu sẫm cho cạnh bộ bài
      ),
    );
  }
}

class _DeckBox extends StatelessWidget {
  const _DeckBox();

  @override
  Widget build(BuildContext context) {
    const cardWidth = 200.0;
    const cardHeight = 350.0;
    const deckDepth = 78 * 0.8;
    const overlap = 1.0; // Small overlap to prevent visual gaps

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Mặt sau
          Transform(
            transform: Matrix4.translationValues(0, 0, -deckDepth / 2),
            child: const _CardFace(),
          ),
          // Mặt trước
          Transform(
            alignment: Alignment.center,
            transform: Matrix4.translationValues(0.0, 0.0, deckDepth / 2)
              ..rotateY(pi),
            child: const _CardFace(),
          ),
          // Mặt trái
          Transform(
            alignment: Alignment.center,
            transform: Matrix4.translationValues(-cardWidth / 2, 0.0, 0.0)
              ..rotateY(-pi / 2),
            child: _DeckSide(width: deckDepth + overlap, height: cardHeight + overlap),
          ),
          // Mặt phải
          Transform(
            alignment: Alignment.center,
            transform: Matrix4.translationValues(cardWidth / 2, 0.0, 0.0)
              ..rotateY(pi / 2),
            child: _DeckSide(width: deckDepth + overlap, height: cardHeight + overlap),
          ),
          // Mặt trên
          Transform(
            alignment: Alignment.center,
            transform: Matrix4.translationValues(0.0, -cardHeight / 2, 0.0)
              ..rotateX(pi / 2),
            child: _DeckSide(width: cardWidth + overlap, height: deckDepth + overlap),
          ),
          // Mặt dưới
          Transform(
            alignment: Alignment.center,
            transform: Matrix4.translationValues(0.0, cardHeight / 2, 0.0)
              ..rotateX(-pi / 2),
            child: _DeckSide(width: cardWidth + overlap, height: deckDepth + overlap),
          ),
        ],
      ),
    );
  }
}

class _CardFace extends StatelessWidget {
  const _CardFace();

  @override
  Widget build(BuildContext context) {
    const overlap = 1.0; // Match the overlap in _DeckBox
    return Container(
      width: 200 + overlap,
      height: 350 + overlap,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/back_card.png'),
          fit: BoxFit.cover,
        ),
      ),
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
                      child: Image.asset(
                        widget.card.imageUrl,
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
    'Lắng nghe tiếng thầm thì của các vì sao...',
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
