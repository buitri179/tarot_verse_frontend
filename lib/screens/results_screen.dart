import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../widgets/star_field.dart';
import '../models/tarot_card.dart';
import '../services/tarot_service.dart';
import '../models/tarot_response.dart';
import 'conclusion_screen.dart';

class ResultsScreen extends StatefulWidget {
  final List<TarotCardModel> selectedCards;
  final List<String> topics;
  final String name;
  final DateTime birthDate;
  final String gender;

  const ResultsScreen({
    super.key,
    required this.selectedCards,
    required this.topics,
    required this.name,
    required this.birthDate,
    required this.gender,
  });

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  int _currentIndex = 0;
  TarotResponse? _apiResponse;
  final TarotService _tarotService = TarotService();
  final Map<String, String> _cardOrientations = {};

  @override
  void initState() {
    super.initState();
    _fetchReading();
  }

  Future<void> _fetchReading() async {
    try {
      // Giả lập trạng thái ngẫu nhiên cho các lá bài (xuôi hoặc ngược)
      for (var card in widget.selectedCards) {
        _cardOrientations[card.name] =
            (DateTime.now().millisecond % 2 == 0) ? 'upright' : 'reversed';
      }

      final cardNames = widget.selectedCards.map((c) => c.name).toList();
      final response = await _tarotService.askTarot(
        name: widget.name,
        birthDate: DateFormat('yyyy-MM-dd').format(widget.birthDate),
        gender: widget.gender,
        topic: widget.topics.join(', '),
        cards: cardNames,
      );

      if (mounted) {
        setState(() {
          _apiResponse = response;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _apiResponse = TarotResponse(
            conclusion: 'Không thể lấy kết quả diễn giải. Vui lòng thử lại.',
            cards: [],
            cardsDetail: {},
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final card = widget.selectedCards[_currentIndex];
    final orientation = _cardOrientations[card.name]!;
    final isFirst = _currentIndex == 0;
    final isLast = _currentIndex == widget.selectedCards.length - 1;

    // Lấy diễn giải chi tiết cho lá bài hiện tại từ API
    final isApiLoading = _apiResponse == null;
    final apiDetail =
        _apiResponse?.cardsDetail?[card.name] ?? 'Chưa có diễn giải từ AI.';

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
                          // Header navigation
                          Row(
                            children: [
                              TextButton.icon(
                                onPressed: () => Navigator.pop(context),
                                label: Text(
                                  'Quay lại',
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
                                  onPressed: () =>
                                      setState(() => _currentIndex--),
                                  color: const Color(0xFFFFD700),
                                ),
                              if (!isLast)
                                IconButton(
                                  icon: const Icon(Icons.chevron_right, size: 36),
                                  onPressed: () =>
                                      setState(() => _currentIndex++),
                                  color: const Color(0xFFFFD700),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Nội dung lá bài
                          Flexible(
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final isNarrow = constraints.maxWidth < 800;
                                return Flex(
                                  direction: isNarrow
                                      ? Axis.vertical
                                      : Axis.horizontal,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      width: isNarrow
                                          ? double.infinity
                                          : constraints.maxWidth * 0.45,
                                      child: AspectRatio(
                                        aspectRatio: 200 / 350,
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Image.asset(
                                            card.imageUrl,
                                            fit: BoxFit.cover,
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
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                            color: Colors.amber.withOpacity(0.2),
                                          ),
                                        ),
                                        child: SingleChildScrollView(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
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
                                              Text(
                                                orientation == 'upright'
                                                    ? card.uprightMeaning
                                                    : card.reversedMeaning,
                                                style: const TextStyle(
                                                    fontSize: 16, height: 1.5),
                                              ),
                                              const SizedBox(height: 4),
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
                                                        'AI đang diễn giải...',
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
                                                  style: const TextStyle(
                                                      fontSize: 16, height: 1.5),
                                                ),
                                              const SizedBox(height: 12),
                                              if (isLast)
                                                Align(
                                                  alignment: Alignment.centerRight,
                                                  child: ElevatedButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          const Color(0xFFFFD700),
                                                      foregroundColor:
                                                          Colors.black,
                                                      shape:
                                                          const StadiumBorder(),
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 24,
                                                        vertical: 14,
                                                      ),
                                                      elevation: 10,
                                                      shadowColor:
                                                          const Color(0x80FFD700),
                                                    ),
                                                    onPressed: () {
                                                      Navigator.of(context).push(
                                                        MaterialPageRoute(
                                                          builder: (_) =>
                                                              ConclusionScreen(
                                                                selected: widget
                                                                    .selectedCards,
                                                                topics: widget.topics,
                                                                name: widget.name,
                                                                birthDate: widget
                                                                    .birthDate,
                                                                gender: widget.gender,
                                                                reading: _apiResponse
                                                                        ?.conclusion ??
                                                                    'Không có kết quả.',
                                                              ),
                                                        ),
                                                      );
                                                    },
                                                    child: const Text(
                                                      'Xem Kết Luận',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w600),
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
  }
}
