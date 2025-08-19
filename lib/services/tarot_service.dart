import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tarot_verse_frontend/models/tarot_response.dart';
/// Class mô tả cấu trúc dữ liệu mà API trả về
/// Bao gồm nội dung giải bài và danh sách các lá bài được chọn.

/// Service class xử lý các cuộc gọi API liên quan đến Tarot
class TarotService {
  // Thay đổi endpoint nếu cần, chú ý khi chạy trên emulator cần dùng IP máy tính
  static const String _endpoint = 'http://localhost:8080/api/tarot/reading';

  /// Gửi yêu cầu giải bài Tarot đến backend
  ///
  /// @param name Tên người dùng
  /// @param birthDate Ngày sinh (format 'yyyy-MM-dd')
  /// @param gender Giới tính
  /// @param topic Chủ đề muốn giải bài
  /// @param question Câu hỏi cụ thể (không bắt buộc)
  ///
  /// @return Future<TarotResponse> - Đối tượng chứa kết quả giải bài từ server
  Future<TarotResponse> askTarot({
    required String name,
    required String birthDate,
    required String gender,
    required String topic,
    required List<String> cards, // Thêm tham số này
    String? question, // Đã thay đổi thành nullable (không bắt buộc)
  }) async {
    try {
      // Chuẩn bị dữ liệu gửi đi (payload)
      final payload = json.encode({
        'name': name,
        'birthDate': birthDate,
        'gender': gender,
        'topic': topic,
        'question': question,
        'cards': cards, // Thêm danh sách lá bài vào payload
      });

      // Gửi yêu cầu HTTP POST
      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: payload,
      );

      // Xử lý response từ server
      if (response.statusCode == 200) {
        // Lấy dữ liệu từ body của response
        final responseData = json.decode(utf8.decode(response.bodyBytes));

        // Tạo đối tượng TarotResponse từ dữ liệu JSON
        return TarotResponse.fromJson(responseData);
      } else {
        // Xử lý khi có lỗi từ server (ví dụ: lỗi 404, 500)
        final errorBody = utf8.decode(response.bodyBytes);
        throw Exception('Failed to load tarot reading. Status code: ${response.statusCode}, Body: $errorBody');
      }
    } catch (e) {
      // Xử lý các lỗi khác như mất kết nối mạng
      print('❌ Error in askTarot: $e');
      throw Exception('An error occurred while asking for a tarot reading: $e');
    }
  }

  /// Phương thức giả lập để lấy 3 lá bài đã xáo trộn từ API
  /// (Bạn có thể thêm endpoint tương ứng ở backend)
  Future<List<Map<String, String>>> getShuffledCards() async {
    // Giả lập 3 lá bài đã được xáo trộn từ một danh sách cố định
    final tarotDeck = [
      {"name": "The Fool", "img": "https://upload.wikimedia.org/wikipedia/commons/5/53/The_Fool_Arcana.jpg", "meaning": "New beginnings, spontaneity, free spirit."},
      {"name": "The Magician", "img": "https://upload.wikimedia.org/wikipedia/commons/d/de/RWS_Tarot_01_Magician.jpg", "meaning": "Manifestation, power, inspired action."},
      {"name": "The High Priestess", "img": "https://upload.wikimedia.org/wikipedia/commons/8/88/RWS_Tarot_02_High_Priestess.jpg", "meaning": "Intuition, sacred knowledge, divine feminine."},
      {"name": "The Empress", "img": "https://upload.wikimedia.org/wikipedia/commons/d/d2/RWS_Tarot_03_Empress.jpg", "meaning": "Femininity, beauty, nature, nurturing."},
      {"name": "The Emperor", "img": "https://upload.wikimedia.org/wikipedia/commons/c/c3/RWS_Tarot_04_Emperor.jpg", "meaning": "Authority, structure, control, fatherhood."},
      {"name": "The Lovers", "img": "https://upload.wikimedia.org/wikipedia/commons/d/db/RWS_Tarot_06_Lovers.jpg", "meaning": "Love, harmony, relationships, values alignment."},
      {"name": "The Chariot", "img": "https://upload.wikimedia.org/wikipedia/commons/9/9b/RWS_Tarot_07_Chariot.jpg", "meaning": "Control, willpower, victory, determination."}
    ];

    // Xáo trộn và lấy 3 lá bài đầu tiên
    tarotDeck.shuffle();
    final shuffledCards = tarotDeck.sublist(0, 3);
    return Future.value(shuffledCards);
  }
}