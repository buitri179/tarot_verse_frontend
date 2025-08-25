
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/star_field.dart';
import 'form_steps.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            'https://images.unsplash.com/photo-1534796636912-3b95b3ab5986?q=80&w=1471&auto=format&fit=crop',
            fit: BoxFit.cover,
          ),
          const StarField(),
          Container(color: Colors.black.withOpacity(0.45)),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'TAROT GALAXY',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cinzelDecorative(
                        fontSize: 52,
                        color: const Color(0xFFFFD700),
                        shadows: const [
                          Shadow(
                            color: Color(0xAAFFD700),
                            blurRadius: 15,
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Khám phá những bí ẩn của vũ trụ và tìm kiếm câu trả lời cho riêng bạn qua những lá bài Tarot kỳ diệu.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lato(
                        fontSize: 18,
                        color: Colors.white.withOpacity(0.85),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 40),
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
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
