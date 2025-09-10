import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/tarot_card.dart';

class TarotDataService {
  // Singleton pattern để đảm bảo chỉ có một instance của service này
  static final TarotDataService _instance = TarotDataService._internal();
  factory TarotDataService() => _instance;
  TarotDataService._internal();

  static TarotDataService get instance => _instance;

  List<TarotCardModel> _cards = [];

  // Getter để các phần khác của ứng dụng có thể truy cập danh sách lá bài
  List<TarotCardModel> get allCards => _cards;

  // Phương thức tải và phân tích tệp JSON
  Future<void> loadCardsFromJson() async {
    if (_cards.isNotEmpty) return; // Chỉ tải một lần

    try {
      // Đọc nội dung tệp JSON từ assets
      final String jsonString = await rootBundle.loadString('assets/tarot_cards.json');
      
      // Phân tích chuỗi JSON thành một List<dynamic>
      final List<dynamic> jsonList = json.decode(jsonString);
      
      // Chuyển đổi mỗi đối tượng JSON thành một TarotCardModel
      _cards = jsonList.map((jsonItem) => TarotCardModel.fromJson(jsonItem)).toList();

      print('✅ TarotDataService: Successfully loaded ${_cards.length} cards.');
    } catch (e) {
      print('❌ TarotDataService: Error loading cards: $e');
      // Có thể xử lý lỗi ở đây, ví dụ: hiển thị thông báo cho người dùng
    }
  }
}
