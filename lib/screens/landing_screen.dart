import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tarot_verse_frontend/services/auth_service.dart';
import '../widgets/star_field.dart';
import 'form_steps.dart';
import 'card_meaning_screen.dart';
import 'history_screen.dart'; // Import the new history screen

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final AuthService _authService = AuthService();
  bool _isLoggedIn = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    setState(() => _isLoading = true);
    try {
      final token = await _authService.getToken();
      setState(() {
        _isLoggedIn = token != null;
      });
    } catch (e) {
      // Handle potential errors if needed
      setState(() {
        _isLoggedIn = false;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    await _authService.logout();
    _checkLoginStatus(); // Refresh the UI
  }

  Widget _buildAuthSection() {
    if (_isLoading) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
      );
    }

    if (_isLoggedIn) {
      return PopupMenuButton<String>(
        onSelected: (value) {
          if (value == 'logout') {
            _logout();
          } else if (value == 'history') {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const HistoryScreen()),
            );
          }
        },
        color: const Color(0xff1B2735),
        icon: const Icon(Icons.account_circle_outlined, color: Colors.white, size: 28),
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
          const PopupMenuItem<String>(
            value: 'logout',
            child: Text('Đăng xuất', style: TextStyle(color: Colors.white)),
          ),
          const PopupMenuItem<String>(
            value: 'history',
            child: Text('Lịch sử đọc bài', style: TextStyle(color: Colors.white)),
          ),
        ],
      );
    } else {
      return TextButton.icon(
        onPressed: () {
          Navigator.of(context).pushNamed('/auth').then((_) => _checkLoginStatus());
        },
        icon: const Icon(Icons.login, color: Colors.white),
        label: const Text(
          'Đăng nhập',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        style: TextButton.styleFrom(
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Colors.white54),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/back_ground.jpg', fit: BoxFit.cover),
          const StarField(),
          Container(color: Colors.black.withOpacity(0.45)),
          Column(
            children: [
              // Navbar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                color: Colors.black.withOpacity(0.5),
                child: Row(
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
                    const Spacer(), // Pushes all subsequent widgets to the right
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
                    const SizedBox(width: 24),
                    _buildAuthSection(), // Auth section remains here
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: Column(
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
                            Shadow(color: Colors.black54, blurRadius: 8),
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
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD700),
                    foregroundColor: Colors.black,
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                    elevation: 10,
                    shadowColor: const Color(0x80FFD700),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const FormStepsScreen()),
                    );
                  },
                  child: const Text(
                    'Trải Bài Ngay',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}