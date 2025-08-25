import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../widgets/star_field.dart';
import '../models/tarot_card.dart';
import '../services/tarot_service.dart';
import '../models/tarot_response.dart';
import 'conclusion_screen.dart';

class ResultsScreen extends StatefulWidget {
  final List<TarotCardModel> selected;
  final List<String> topics;
  final String name;
  final DateTime birthDate;
  final String gender;

  const ResultsScreen({
    super.key,
    required this.selected,
    required this.topics,
    required this.name,
    required this.birthDate,
    required this.gender,
  });

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  int index = 0;
  bool _isLoading = true;
  TarotResponse? _apiResponse;
  final TarotService _tarotService = TarotService();

  @override
  void initState() {
    super.initState();
    _fetchReading();
  }

  Future<void> _fetchReading() async {
    try {
      final cardNames = widget.selected.map((card) => card.name).toList();
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
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching tarot reading: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _apiResponse = TarotResponse(reading: 'Không thể lấy kết quả diễn giải. Vui lòng thử lại.');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: Image.network(
                'https://images.unsplash.com/photo-1534796636912-3b95b3ab5986?q=80&w=1471&auto=format&fit=cover',
                fit: BoxFit.cover,
              ),
            ),
            const StarField(),
            const Center(
              child: CircularProgressIndicator(color: Color(0xFFFFD700)),
            ),
          ],
        ),
      );
    }

    final card = widget.selected[index];
    final isFirst = index == 0;
    final isLast = index == widget.selected.length - 1;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Image.network(
              'https://images.unsplash.com/photo-1534796636912-3b95b3ab5986?q=80&w=1471&auto=format&fit=cover',
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
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                                onPressed: () => Navigator.pop(context),
                                color: const Color(0xFFFFD700),
                              ),
                              const Spacer(),
                              if (!isFirst)
                                IconButton(
                                  icon: const Icon(Icons.chevron_left, size: 36),
                                  onPressed: () => setState(() => index--),
                                  color: const Color(0xFFFFD700),
                                ),
                              if (!isLast)
                                IconButton(
                                  icon: const Icon(Icons.chevron_right, size: 36),
                                  onPressed: () => setState(() => index++),
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
                                          child: Image.network(card.image, fit: BoxFit.cover),
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
                                              Text(card.name, style: GoogleFonts.cinzelDecorative(fontSize: 22)),
                                              const SizedBox(height: 8),
                                              Text(
                                                _apiResponse?.reading ?? 'Không có kết quả diễn giải.',
                                                style: const TextStyle(fontSize: 16, height: 1.5),
                                              ),
                                              const SizedBox(height: 12),
                                              if (isLast)
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
                                                      Navigator.of(context).push(
                                                        MaterialPageRoute(
                                                          builder: (_) => ConclusionScreen(
                                                            selected: widget.selected,
                                                            topics: widget.topics,
                                                            name: widget.name,
                                                            birthDate: widget.birthDate,
                                                            gender: widget.gender,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    child: const Text('Xem Kết Luận', style: TextStyle(fontWeight: FontWeight.w600)),
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