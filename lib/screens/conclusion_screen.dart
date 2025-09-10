import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/star_field.dart';
import '../models/tarot_card.dart';

class ConclusionScreen extends StatefulWidget {
  final List<TarotCardModel> selected;
  final List<String> topics;
  final String name;
  final DateTime birthDate;
  final String gender;
  final String reading;

  const ConclusionScreen({
    super.key,
    required this.selected,
    required this.topics,
    required this.name,
    required this.birthDate,
    required this.gender,
    required this.reading,
  });

  @override
  State<ConclusionScreen> createState() => _ConclusionScreenState();
}

class _ConclusionScreenState extends State<ConclusionScreen> {
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
                        children: [
                          // Nội dung cuộn được
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'Kết Luận',
                                    style: GoogleFonts.cinzelDecorative(
                                      fontSize: 26,
                                      color: const Color(0xFFFFD700),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Chủ đề: ${widget.topics.join(', ')}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(height: 20),

                                  // Hàng thẻ bài
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
                                              c.imageUrl,
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

                                  // Ô kết quả bói
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: const Color(0xB0000000),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Colors.amber.withOpacity(0.15)),
                                    ),
                                    child: Text(
                                      widget.reading,
                                      style: const TextStyle(fontSize: 16, height: 1.5),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Nút hành động (luôn cố định cuối)
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
                                child: const Text(
                                  'Bói Lại',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
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
                                child: const Text(
                                  'Quay lại',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
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
}