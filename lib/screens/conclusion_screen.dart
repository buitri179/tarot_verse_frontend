import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../widgets/star_field.dart';
import '../models/tarot_card.dart';
import '../models/reading_model.dart';
import '../config.dart';
import '../services/auth_service.dart';
import '../services/tarot_service.dart';

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
  final AuthService _authService = AuthService();
  final TarotService _tarotService = TarotService();
  bool _isLoading = false;
  int? _savedReadingId;

  Future<void> _saveReading() async {
    if (_savedReadingId != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kết quả bói đã được lưu rồi.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final isAuthenticated = await _authService.getToken() != null;

      if (isAuthenticated) {
        await _executeSaveReading();
      } else {
        _showLoginDialog();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _executeSaveReading() async {
    try {
      final readingToSave = Reading(
        question: widget.topics.join(', '),
        cards: widget.selected.map((c) => c.name).join(', '),
        interpretation: widget.reading,
        createdAt: DateTime.now(),
      );
      final savedReading = await _tarotService.saveReading(readingToSave);
      if (mounted) {
        setState(() {
          _savedReadingId = savedReading.id;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lịch sử bói bài đã được lưu thành công!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lưu lịch sử bói thất bại: ${e.toString()}')),
        );
      }
    }
  }

  void _shareReading() {
    if (_savedReadingId == null) return;
    // IMPORTANT: Replace with your actual Vercel domain
    const vercelDomain = 'tarot-verse-frontend-wark.vercel.app';
    final shareUrl = 'https://$vercelDomain/share/reading/$_savedReadingId';
    Share.share('Xem kết quả bói bài Tarot của tôi tại đây: $shareUrl');
  }

  void _showLoginDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Lưu Lịch Sử'),
        content: const Text('Bạn cần đăng nhập để lưu kết quả bói bài. Bạn có muốn đăng nhập ngay không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              final result = await context.push('/auth');

              // After returning from AuthScreen, check login status and try saving again
              if (result == true) {
                await _executeSaveReading();
              }
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isReadingSaved = _savedReadingId != null;

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
                                              '$baseUrl/${c.imageUrl}',
                                              width: 150,
                                              height: 240,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                return Container(
                                                  width: 150,
                                                  height: 240,
                                                  color: Colors.grey[800],
                                                  child: const Icon(Icons.image_not_supported, color: Colors.white54),
                                                );
                                              },
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
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 12.0,
                            runSpacing: 12.0,
                            children: [
                              ElevatedButton.icon(
                                icon: const Icon(Icons.refresh),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFFD700),
                                  foregroundColor: Colors.black,
                                  shape: const StadiumBorder(),
                                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                                  elevation: 8,
                                  shadowColor: const Color(0x80FFD700),
                                ),
                                onPressed: () => context.go('/'),
                                label: const Text(
                                  'Bói Lại',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ),
                              ElevatedButton.icon(
                                icon: _isLoading
                                    ? const SizedBox.shrink()
                                    : Icon(isReadingSaved ? Icons.check_circle : Icons.save),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isReadingSaved ? Colors.green.withOpacity(0.5) : Colors.transparent,
                                  foregroundColor: isReadingSaved ? Colors.white : const Color(0xFFFFD700),
                                  side: isReadingSaved ? null : BorderSide(color: Colors.amber.withOpacity(0.2)),
                                  shape: const StadiumBorder(),
                                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                                ),
                                onPressed: (_isLoading || isReadingSaved) ? null : _saveReading,
                                label: _isLoading
                                    ? const CircularProgressIndicator(color: Color(0xFFFFD700))
                                    : Text(
                                  isReadingSaved ? 'Đã Lưu' : 'Lưu Kết Quả',
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ),
                              if (isReadingSaved)
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.share),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blueAccent,
                                    foregroundColor: Colors.white,
                                    shape: const StadiumBorder(),
                                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                                    elevation: 8,
                                    shadowColor: Colors.blueAccent.withOpacity(0.5),
                                  ),
                                  onPressed: _shareReading,
                                  label: const Text(
                                    'Chia sẻ',
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
