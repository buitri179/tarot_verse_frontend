import 'dart:ui'; // cần để dùng ImageFilter
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/star_field.dart';
import 'form_steps.dart';
import 'card_meaning_screen.dart'; // màn hình xem ý nghĩa lá bài

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background galaxy
          Image.asset(
            'assets/images/back_ground.jpg',
            fit: BoxFit.cover,
          ),
          const StarField(),
          Container(color: Colors.black.withOpacity(0.45)),

          // Nội dung chính
          Column(
            children: [
              // Navbar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                color: Colors.black.withOpacity(0.5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'TAROT GALAXY',
                      style: GoogleFonts.cinzelDecorative(
                        fontSize: 28,
                        color: const Color(0xFFFFD700),
                        fontWeight: FontWeight.bold,
                        shadows: const [
                          Shadow(color: Color(0xAAFFD700), blurRadius: 10),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const FormStepsScreen()),
                            );
                          },
                          child: const Text(
                            'Bói Bài',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                        const SizedBox(width: 16),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const CardMeaningScreen()),
                            );
                          },
                          child: const Text(
                            'Xem Ý Nghĩa Lá Bài',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),

              // Spacer với background cô gái + overlay text
              Expanded(
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Overlay text
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Khám phá những bí ẩn vũ trụ\nvà tìm câu trả lời cho riêng bạn',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.cinzelDecorative(
                              fontSize: 28,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              shadows: const [
                                Shadow(
                                  color: Colors.black54,
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Với Tarot Galaxy WebApp',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.lato(
                              fontSize: 20,
                              color: Colors.white70,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Call-to-action buttons
              Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: Column(
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD700),
                        foregroundColor: Colors.black,
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                        elevation: 10,
                        shadowColor: const Color(0x80FFD700),
                      ),
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const FormStepsScreen()),
                        );
                      },
                      child: const Text(
                        'Trải Bài Ngay',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
