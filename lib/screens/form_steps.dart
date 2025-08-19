import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../widgets/star_field.dart';
import 'deck_screen.dart';

class FormStepsScreen extends StatefulWidget {
  const FormStepsScreen({super.key});

  @override
  State<FormStepsScreen> createState() => _FormStepsScreenState();
}

class _FormStepsScreenState extends State<FormStepsScreen> {
  int step = 1;
  final nameCtrl = TextEditingController();
  DateTime? birthdate;
  String? gender;
  String? topic;

  void next() {
    if (step == 1) {
      if (nameCtrl.text.trim().isEmpty) {
        _alert('Vui lòng nhập họ và tên.');
        return;
      }
    } else if (step == 2) {
      if (birthdate == null) {
        _alert('Vui lòng chọn ngày sinh.');
        return;
      }
    } else if (step == 3) {
      if (gender == null || gender!.isEmpty) {
        _alert('Vui lòng chọn giới tính.');
        return;
      }
    }
    setState(() => step++);
  }

  void back() {
    if (step > 1) {
      setState(() => step--);
    }
  }

  void _alert(String msg) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: const Color(0xFF111111),
        title: const Text('Thông báo'),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('OK'),
          )
        ],
      ),
    );
  }

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
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Card(
                  color: const Color(0xAA000000),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: BorderSide(color: Colors.amber.withOpacity(0.2)),
                  ),
                  elevation: 12,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 28,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'TAROT GALAXY',
                          style: GoogleFonts.cinzelDecorative(
                            fontSize: 28,
                            color: const Color(0xFFFFD700),
                            shadows: const [
                              Shadow(
                                color: Color(0x88FFD700),
                                blurRadius: 12,
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Nhập thông tin của bạn để nhận được lời tiên tri từ các vì sao',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        if (step == 1) _step1(),
                        if (step == 2) _step2(),
                        if (step == 3) _step3(),
                        if (step == 4) _step4(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _goldButton(String text, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFD700),
          foregroundColor: Colors.black,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          elevation: 10,
          shadowColor: const Color(0x80FFD700),
        ),
        onPressed: onTap,
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }

  InputDecoration _decor(String hint) => InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: const Color(0x80000000),
    hintStyle: const TextStyle(color: Color(0xFFFFD700)),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0x80FFD700)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFFFFD700), width: 2),
    ),
  );

  Widget _step1() => Column(
    children: [
      Text('Họ và Tên', style: GoogleFonts.cinzelDecorative(fontSize: 22)),
      const SizedBox(height: 10),
      Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: TextField(
            controller: nameCtrl,
            style: const TextStyle(color: Colors.white),
            decoration: _decor('Nhập họ và tên của bạn'),
          ),
        ),
      ),
      _goldButton('Tiếp Theo', next),
    ],
  );

  Widget _step2() => Column(
    children: [
      Text('Ngày Tháng Năm Sinh',
          style: GoogleFonts.cinzelDecorative(fontSize: 22)),
      const SizedBox(height: 10),
      Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: InkWell(
            onTap: () async {
              final now = DateTime.now();
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime(now.year - 18),
                firstDate: DateTime(1900),
                lastDate: now,
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      dialogBackgroundColor: const Color(0xFF0E0E0E),
                      colorScheme: Theme.of(context).colorScheme.copyWith(
                        primary: const Color(0xFFFFD700),
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null) setState(() => birthdate = picked);
            },
            child: InputDecorator(
              decoration: _decor('Chọn ngày sinh'),
              child: Text(
                birthdate == null
                    ? ''
                    : DateFormat('dd/MM/yyyy').format(birthdate!),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _goldButton('Quay Lại', back),
          const SizedBox(width: 12),
          _goldButton('Tiếp Theo', next),
        ],
      )
    ],
  );

  Widget _step3() => Column(
    children: [
      Text('Giới Tính', style: GoogleFonts.cinzelDecorative(fontSize: 22)),
      const SizedBox(height: 10),
      Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: DropdownButtonFormField<String>(
            value: gender,
            dropdownColor: Colors.black,
            style: const TextStyle(color: Colors.white),
            decoration: _decor('Chọn giới tính'),
            items: const [
              DropdownMenuItem(value: 'male', child: Text('Nam')),
              DropdownMenuItem(value: 'female', child: Text('Nữ')),
              DropdownMenuItem(value: 'other', child: Text('Khác')),
            ],
            onChanged: (v) => setState(() => gender = v),
          ),
        ),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _goldButton('Quay Lại', back),
          const SizedBox(width: 12),
          _goldButton('Tiếp Theo', next),
        ],
      )
    ],
  );

  Widget _step4() => Column(
    children: [
      Text('Chủ Đề Bói',
          style: GoogleFonts.cinzelDecorative(fontSize: 22)),
      const SizedBox(height: 10),
      Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: DropdownButtonFormField<String>(
            value: topic,
            dropdownColor: Colors.black,
            style: const TextStyle(color: Colors.white),
            decoration: _decor('Chọn chủ đề bạn quan tâm'),
            items: const [
              DropdownMenuItem(value: 'love', child: Text('Tình yêu')),
              DropdownMenuItem(value: 'career', child: Text('Sự nghiệp')),
              DropdownMenuItem(value: 'finance', child: Text('Tài chính')),
              DropdownMenuItem(value: 'health', child: Text('Sức khỏe')),
              DropdownMenuItem(value: 'spirituality', child: Text('Tâm linh')),
            ],
            onChanged: (v) => setState(() => topic = v),
          ),
        ),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _goldButton('Quay Lại', back),
          const SizedBox(width: 12),
          _goldButton('Bắt Đầu Bói Bài', () {
            if (topic == null || topic!.isEmpty) {
              _alert('Vui lòng chọn chủ đề bói');
              return;
            }
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => DeckScreen(
                  topic: topic!,
                  name: nameCtrl.text,
                  birthDate: birthdate!,
                  gender: gender!,
                ),
              ),
            );
          }),
        ],
      )
    ],
  );
}