import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Import các tệp khác nếu bạn có
// import 'package:tarot_verse_frontend/services/auth_service.dart';
// import 'history_screen.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  // Giả lập dịch vụ xác thực và thông tin người dùng
  String? _username = 'Guest'; // Bạn có thể đổi thành null để kiểm tra trạng thái chưa đăng nhập

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tarot Verse',
          style: GoogleFonts.cinzelDecorative(),
        ),
        actions: [
          if (_username != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Text('Xin chào, $_username'),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Navigator.of(context).push(
                      //   MaterialPageRoute(builder: (context) => const HistoryScreen()),
                      // );
                      // Giả lập chức năng Lịch sử
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Chức năng Lịch sử chưa được tích hợp.')),
                      );
                    },
                    child: const Text('Lịch sử'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _username = null;
                      });
                      // Navigator.of(context).pushReplacementNamed('/auth');
                    },
                    child: const Text('Đăng xuất'),
                  ),
                ],
              ),
            )
          else
            ElevatedButton(
              onPressed: () {
                // Navigator.of(context).pushNamed('/auth');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Chức năng Đăng nhập chưa được tích hợp.')),
                );
              },
              child: const Text('Đăng nhập / Đăng ký'),
            ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Chào mừng đến với Tarot Verse!',
              style: GoogleFonts.cinzelDecorative(fontSize: 24),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                // Điều hướng đến màn hình bói bài (giả lập)
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const TarotReadingScreen()),
                );
              },
              icon: const Icon(Icons.star, color: Color(0xFFFFD700)),
              label: const Text('Bói Bài Tarot'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                backgroundColor: const Color(0xFF1A1A1A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                  side: const BorderSide(color: Color(0xFFFFD700)),
                ),
                elevation: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// --- Màn hình bói bài đơn giản (Giả lập) ---
// Dán mã này vào cuối tệp hoặc tạo một tệp mới 'tarot_reading_screen.dart'

class TarotReadingScreen extends StatefulWidget {
  const TarotReadingScreen({super.key});

  @override
  State<TarotReadingScreen> createState() => _TarotReadingScreenState();
}

class _TarotReadingScreenState extends State<TarotReadingScreen> {
  final List<String> _cards = ['Lá số 1', 'Lá số 2', 'Lá số 3', 'Lá số 4', 'Lá số 5'];
  final List<String> _selectedCards = [];
  String _readingResult = '';

  void _selectCard(String card) {
    if (_selectedCards.length < 3 && !_selectedCards.contains(card)) {
      setState(() {
        _selectedCards.add(card);
      });
      if (_selectedCards.length == 3) {
        _generateReading();
      }
    }
  }

  void _generateReading() {
    setState(() {
      _readingResult = 'Kết quả bói bài của bạn là: ${_selectedCards.join(', ')}. Hãy tin vào định mệnh!';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bói Bài Tarot'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Chọn 3 lá bài để bói:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: _cards.length,
                itemBuilder: (context, index) {
                  final card = _cards[index];
                  return GestureDetector(
                    onTap: () => _selectCard(card),
                    child: Card(
                      color: _selectedCards.contains(card) ? Colors.amber : Colors.blueGrey,
                      child: Center(
                        child: Text(
                          'Lá số ${index + 1}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            if (_selectedCards.isNotEmpty)
              Text(
                'Bạn đã chọn: ${_selectedCards.join(', ')}',
                style: const TextStyle(fontSize: 18),
              ),
            const SizedBox(height: 20),
            if (_readingResult.isNotEmpty)
              Card(
                color: Colors.black.withOpacity(0.5),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _readingResult,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
