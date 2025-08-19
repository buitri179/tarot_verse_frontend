import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/form_steps.dart';

void main() {
  runApp(const TarotGalaxyApp());
}

class TarotGalaxyApp extends StatelessWidget {
  const TarotGalaxyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mystic Tarot Galaxy',
      theme: ThemeData(
        // Cấu hình theme cho toàn bộ ứng dụng
        brightness: Brightness.dark,
        primaryColor: const Color(0xff8b5cf6),
        scaffoldBackgroundColor: const Color(0xff090A0F),
        textTheme: GoogleFonts.cinzelDecorativeTextTheme().copyWith(
          // Cập nhật màu chữ để dễ đọc hơn
          bodyLarge: const TextStyle(color: Color(0xffe0d6e9)),
          bodyMedium: const TextStyle(color: Color(0xffe0d6e9)),
          displayLarge: const TextStyle(color: Color(0xffe0d6e9)),
          displayMedium: const TextStyle(color: Color(0xffe0d6e9)),
          displaySmall: const TextStyle(color: Color(0xffe0d6e9)),
          headlineLarge: const TextStyle(color: Color(0xffe0d6e9)),
          headlineMedium: const TextStyle(color: Color(0xffe0d6e9)),
          headlineSmall: const TextStyle(color: Color(0xffe0d6e9)),
          titleLarge: const TextStyle(color: Color(0xffe0d6e9)),
          titleMedium: const TextStyle(color: Color(0xffe0d6e9)),
          titleSmall: const TextStyle(color: Color(0xffe0d6e9)),
          labelLarge: const TextStyle(color: Color(0xffe0d6e9)),
          labelMedium: const TextStyle(color: Color(0xffe0d6e9)),
          labelSmall: const TextStyle(color: Color(0xffe0d6e9)),
        ),
        dialogBackgroundColor: const Color(0xff1B2735),
      ),
      // Đặt màn hình khởi đầu là FormStepsScreen
      home: const FormStepsScreen(),
    );
  }
}