import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:tarot_verse_frontend/data/tarot_data.dart';
import '../widgets/star_field.dart';
import '../models/tarot_card.dart';
import '../services/tarot_service.dart';
import '../models/tarot_response.dart';
import '../models/reading_model.dart';
import 'conclusion_screen.dart';
import '../config.dart';

class ResultsScreen extends StatefulWidget {
  final List<TarotCardModel>? selectedCards;
  final List<String>? topics;
  final String? name;
  final DateTime? birthDate;
  final String? gender;
  final String? readingId;

  const ResultsScreen({
    super.key,
    this.selectedCards,
    this.topics,
    this.name,
    this.birthDate,
    this.gender,
    this.readingId,
  });

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  int _currentIndex = 0;
  TarotResponse? _apiResponse;
  Future<void>? _fetchFuture;
  final TarotService _tarotService = TarotService();
  List<TarotCardModel> _cardsToDisplay = [];

  @override
  void initState() {
    super.initState();
    _fetchFuture = _fetchData();
  }

  Future<void> _fetchData() async {
    if (widget.readingId != null) {
      await _fetchSharedReading(widget.readingId!);
    } else if (widget.selectedCards != null && widget.selectedCards!.isNotEmpty) {
      await _fetchNewReading();
    }
  }

  Future<void> _fetchSharedReading(String readingId) async {
    try {
      final Reading sharedReading = await _tarotService.getSharedReading(readingId);
      final cardNames = sharedReading.cards.split(', ');
      final allCards = TarotDataService.instance.allCards;
      final fetchedCards = cardNames.map((name) => allCards.firstWhere((card) => card.name == name)).toList();

      // Simulate a TarotResponse from the shared reading data
      final simulatedResponse = TarotResponse(
        conclusion: sharedReading.interpretation,
        drawnCards: [], // Not available in this context
        cardsDetail: { for (var name in cardNames) name: 'Interpretation from shared reading.' }, // Placeholder
      );

      if (mounted) {
        setState(() {
          _cardsToDisplay = fetchedCards;
          _apiResponse = simulatedResponse;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _apiResponse = TarotResponse(
            conclusion: 'Không thể tải lượt đọc được chia sẻ. Vui lòng thử lại. Lỗi: $e',
            drawnCards: [],
            cardsDetail: {},
          );
        });
      }
    }
  }

  Future<void> _fetchNewReading() async {
    try {
      final response = await _tarotService.askTarot(
        name: widget.name!,
        birthDate: DateFormat('yyyy-MM-dd').format(widget.birthDate!),
        gender: widget.gender!,
        topic: widget.topics!.join(', '),
        cards: widget.selectedCards!.map((c) => c.name).toList(),
      );

      if (mounted) {
        setState(() {
          _cardsToDisplay = widget.selectedCards!;
          _apiResponse = response;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _apiResponse = TarotResponse(
            conclusion: 'Không thể lấy kết quả diễn giải. Vui lòng thử lại.',
            drawnCards: [],
            cardsDetail: {},
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _fetchFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && _apiResponse == null) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 20),
                  Text(
                    widget.readingId != null
                        ? 'Đang tải lượt đọc được chia sẻ...'
                        : 'Đang kết nối với năng lượng của vũ trụ...',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          );
        }

        if (_cardsToDisplay.isEmpty) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_apiResponse?.conclusion ?? 'Không có lá bài nào được chọn hoặc không thể tải dữ liệu.'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => context.go('/'),
                    child: const Text('Về trang chủ'),
                  ),
                ],
              ),
            ),
          );
        }

        final card = _cardsToDisplay[_currentIndex];
        final isFirst = _currentIndex == 0;
        final isLast = _currentIndex == _cardsToDisplay.length - 1;
        final isApiLoading = _apiResponse == null;
        final apiDetail = _apiResponse?.cardsDetail?[card.name] ?? 'Chưa có diễn giải từ AI.';

        return Scaffold(
          body: Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                child: Image.asset('assets/images/back_ground.jpg', fit: BoxFit.cover),
              ),
              const StarField(),
              Container(color: Colors.black.withOpacity(0.45)),
              SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Card(
                        color: const Color(0xB0000000),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                          side: BorderSide(color: Colors.amber.withOpacity(0.2)),
                        ),
                        elevation: 12,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  TextButton.icon(
                                    onPressed: () => context.go('/'),
                                    label: Text(
                                      'Trang chủ',
                                      style: GoogleFonts.cinzelDecorative(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    style: TextButton.styleFrom(
                                      foregroundColor: const Color(0xFFFFD700),
                                    ),
                                  ),
                                  const Spacer(),
                                  if (!isFirst)
                                    IconButton(
                                      icon: const Icon(Icons.chevron_left, size: 36),
                                      onPressed: () => setState(() => _currentIndex--),
                                      color: const Color(0xFFFFD700),
                                    ),
                                  if (!isLast)
                                    IconButton(
                                      icon: const Icon(Icons.chevron_right, size: 36),
                                      onPressed: () => setState(() => _currentIndex++),
                                      color: const Color(0xFFFFD700),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Flexible(
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    final isNarrow = constraints.maxWidth < 800;
                                    return Flex(
                                      direction: isNarrow ? Axis.vertical : Axis.horizontal,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(
                                          width: isNarrow ? double.infinity : constraints.maxWidth * 0.45,
                                          child: AspectRatio(
                                            aspectRatio: 200 / 350,
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(10),
                                              child: Image.network(
                                                '${baseUrl}/${card.imageUrl}',
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) {
                                                  return Container(
                                                    color: Colors.grey[800],
                                                    child: const Icon(Icons.image_not_supported, color: Colors.white54),
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 16, width: 16),
                                        Expanded(
                                          child: Container(
                                            padding: const EdgeInsets.all(20),
                                            decoration: BoxDecoration(
                                              color: const Color(0xB0000000),
                                              borderRadius: BorderRadius.circular(10),
                                              border: Border.all(color: Colors.amber.withOpacity(0.2)),
                                            ),
                                            child: SingleChildScrollView(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    card.name,
                                                    style: GoogleFonts.cinzelDecorative(
                                                      fontSize: 22,
                                                      color: const Color(0xFFFFD700),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  if (isApiLoading)
                                                    Padding(
                                                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          const SizedBox(
                                                            width: 16,
                                                            height: 16,
                                                            child: CircularProgressIndicator(
                                                              strokeWidth: 2,
                                                              color: Color(0xFFFFD700),
                                                            ),
                                                          ),
                                                          const SizedBox(width: 12),
                                                          Text(
                                                            'Đang kết nối với năng lượng của vũ trụ...',
                                                            style: TextStyle(
                                                              fontStyle: FontStyle.italic,
                                                              color: Colors.white.withOpacity(0.7),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  else
                                                    Text(
                                                      apiDetail,
                                                      style: const TextStyle(fontSize: 16, height: 1.5),
                                                    ),
                                                  const SizedBox(height: 12),
                                                  if (isLast && widget.readingId == null)
                                                    Align(
                                                      alignment: Alignment.centerRight,
                                                      child: ElevatedButton(
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor: const Color(0xFFFFD700),
                                                          foregroundColor: Colors.black,
                                                          shape: const StadiumBorder(),
                                                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                                                          elevation: 10,
                                                          shadowColor: const Color(0x80FFD700),
                                                        ),
                                                        onPressed: () {
                                                          context.push('/conclusion', extra: {
                                                            'selected': widget.selectedCards!,
                                                            'topics': widget.topics!,
                                                            'name': widget.name!,
                                                            'birthDate': widget.birthDate!,
                                                            'gender': widget.gender!,
                                                            'reading': _apiResponse?.conclusion ?? 'Không có kết quả.',
                                                          });
                                                        },
                                                        child: const Text(
                                                          'Xem Kết Luận',
                                                          style: TextStyle(fontWeight: FontWeight.w600),
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
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
