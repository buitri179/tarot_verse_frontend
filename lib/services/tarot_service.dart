import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/tarot_response.dart';
import '../models/reading_model.dart';
import '../models/tarot_card.dart';

class TarotService {
  static const String _readingEndpoint = 'http://localhost:8080/api/tarot/reading';
  static const String _saveEndpoint = 'http://localhost:8080/api/tarot/readings';
  static const String _shareEndpoint = 'http://localhost:8080/tarot/api/share'; // New endpoint

  Future<Reading> getSharedReading(String readingId) async {
    try {
      final response = await http.get(
        Uri.parse('$_shareEndpoint/$readingId'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(utf8.decode(response.bodyBytes));
        return Reading.fromJson(responseData);
      } else {
        final errorBody = utf8.decode(response.bodyBytes);
        throw Exception('Failed to load shared reading. Status code: ${response.statusCode}, Body: $errorBody');
      }
    } catch (e) {
      print('❌ Error in getSharedReading: $e');
      throw Exception('An error occurred while fetching the shared reading: $e');
    }
  }

  Future<TarotResponse> askTarot({
    required String name,
    required String birthDate,
    required String gender,
    required String topic,
    required List<String> cards,
  }) async {
    try {
      final payload = json.encode({
        'name': name,
        'birthDate': birthDate,
        'gender': gender,
        'topic': topic,
        'cards': cards,
      });

      final response = await http.post(
        Uri.parse(_readingEndpoint),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: payload,
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(utf8.decode(response.bodyBytes));
        return TarotResponse.fromJson(responseData);
      } else {
        final errorBody = utf8.decode(response.bodyBytes);
        throw Exception('Failed to load tarot reading. Status code: ${response.statusCode}, Body: $errorBody');
      }
    } catch (e) {
      print('❌ Error in askTarot: $e');
      throw Exception('An error occurred while asking for a tarot reading: $e');
    }
  }

  Future<Reading> saveReading(Reading reading) async {
    try {
      // First, get the auth token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');
      if (token == null) {
        throw Exception('Authentication token not found. Please log in.');
      }

      final response = await http.post(
        Uri.parse(_saveEndpoint),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token', // Include the token in the header
        },
        body: json.encode(reading.toJson()),
      );

      if (response.statusCode == 201) {
        // Decode the response and return the created Reading object
        final responseData = json.decode(utf8.decode(response.bodyBytes));
        return Reading.fromJson(responseData);
      } else {
        throw Exception('Failed to save reading. Status code: ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e) {
      print('❌ Error in saveReading: $e');
      throw Exception('An error occurred while saving the reading: $e');
    }
  }

  Future<List<Reading>> fetchReadingHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');
      if (token == null) {
        throw Exception('Authentication token not found. Please log in.');
      }

      final response = await http.get(
        Uri.parse(_saveEndpoint),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(utf8.decode(response.bodyBytes));
        return jsonList.map((json) => Reading.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch reading history. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error in fetchReadingHistory: $e');
      throw Exception('An error occurred while fetching the history: $e');
    }
  }
}
