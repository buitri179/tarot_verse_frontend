import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../widgets/star_field.dart';
import '../models/tarot_card.dart';
import '../services/tarot_service.dart';

class ConclusionScreen extends StatefulWidget {
  final List<TarotCardModel> selected;
  final List<String> topics;
  final String name;
  final DateTime birthDate;
  final String gender;

  const ConclusionScreen({
    super.key,
    required this.selected,
    required this.topics,
    required this.name,
    required this.birthDate,
    required this.gender,
  });

  @override
  State<ConclusionScreen> createState() => _ConclusionScreenState();
}

class _ConclusionScreenState extends State<ConclusionScreen> {
  final TarotService _tarotService = TarotService();
  late Future<String> _tarotReadingFuture;

  @override
  void initState() {
    super.initState();
    _tarotReadingFuture = _fetchTarotReading();
  }

  Future<String> _fetchTarotReading() async {
    try {
      final cardNames = widget.selected.map((c) => c.name).toList();
      final response = await _tarotService.askTarot(
        name: widget.name,
        birthDate: DateFormat('yyyy-MM-dd').format(widget.birthDate),
        gender: widget.gender,
        topic: widget.topics.join(', '),
        cards: cardNames,
      );
      return response.reading ?? 'Không có kết quả giải bài chi tiết.';
    } catch (e) {
      return 'Đã xảy ra lỗi khi lấy kết quả giải bài. Vui lòng thử lại. ($e)';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Sửa lỗi bố cục: Bọc Image và Container trong Positioned.fill
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
                          Text(
                            'Kết Luận',
                            style: GoogleFonts.cinzelDecorative(fontSize: 26, color: const Color(0xFFFFD700)),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Chủ đề: ${widget.topics.join(', ')}', // Sử dụng trực tiếp topic
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 20),

                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: widget.selected.map((c) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      c.image,
                                      width: 150,
                                      height: 240,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),

                          const SizedBox(height: 20),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xB0000000),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.amber.withOpacity(0.15)),
                            ),
                            child: FutureBuilder<String>(
                              future: _tarotReadingFuture,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const Center(child: CircularProgressIndicator(color: Color(0xFFFFD700)));
                                } else if (snapshot.hasData) {
                                  return Text(
                                    snapshot.data!,
                                    style: const TextStyle(fontSize: 16, height: 1.5),
                                  );
                                } else if (snapshot.hasError) {
                                  return Text(
                                    snapshot.error.toString(),
                                    style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.redAccent),
                                  );
                                } else {
                                  return const Text('Không có dữ liệu.');
                                }
                              },
                            ),
                          ),

                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFFD700),
                                  foregroundColor: Colors.black,
                                  shape: const StadiumBorder(),
                                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                                  elevation: 8,
                                  shadowColor: const Color(0x80FFD700),
                                ),
                                onPressed: () {
                                  Navigator.of(context).popUntil((route) => route.isFirst);
                                },
                                child: const Text('Bói Lại', style: TextStyle(fontWeight: FontWeight.w600)),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  foregroundColor: const Color(0xFFFFD700),
                                  side: BorderSide(color: Colors.amber.withOpacity(0.2)),
                                  shape: const StadiumBorder(),
                                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                                  elevation: 0,
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Quay lại', style: TextStyle(fontWeight: FontWeight.w600)),
                              ),
                            ],
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

// Xóa hàm _topicToLabel không cần thiết
}