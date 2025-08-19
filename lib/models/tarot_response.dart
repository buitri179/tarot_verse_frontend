// File: models/tarot_response.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

/// Class mô tả cấu trúc dữ liệu mà API trả về
/// Bao gồm nội dung giải bài và danh sách các lá bài được chọn.
class TarotResponse {
  final String? reading;
  final List<String>? cards;

  TarotResponse({this.reading, this.cards});

  /// Factory constructor để tạo đối tượng TarotResponse từ JSON.
  factory TarotResponse.fromJson(Map<String, dynamic> json) {
    // In ra toàn bộ JSON nhận được để dễ debug
    print('🔍 JSON received: $json');

    return TarotResponse(
      // Lấy nội dung giải bài từ key 'reading'
      reading: json['reading'] as String?,
      // Lấy danh sách các lá bài từ key 'cards'
      // Ép kiểu List<dynamic> sang List<String>
      cards: (json['cards'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
    );
  }
}