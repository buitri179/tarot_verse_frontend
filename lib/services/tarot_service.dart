import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tarot_verse_frontend/models/tarot_response.dart';

class TarotService {
  // Endpoint của backend
  static const String _endpoint = 'http://localhost:8080/api/tarot/reading';

  /// Gửi yêu cầu giải bài Tarot đến backend.
  /// Backend sẽ tự rút bài và trả về kết quả diễn giải.
  Future<TarotResponse> askTarot({
    required String name,
    required String birthDate,
    required String gender,
    required String topic,
    String? question,
  }) async {
    try {
      final payload = json.encode({
        'name': name,
        'birthDate': birthDate,
        'gender': gender,
        'topic': topic,
        'question': question,
      });

      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: payload,
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(utf8.decode(response.bodyBytes));
        return TarotResponse.fromJson(responseData);
      } else {
        final errorBody = utf8.decode(response.bodyBytes);
        throw Exception(
            'Failed to load tarot reading. Status code: ${response.statusCode}, Body: $errorBody');
      }
    } catch (e) {
      print('❌ Error in askTarot: $e');
      throw Exception('An error occurred while asking for a tarot reading: $e');
    }
  }
}