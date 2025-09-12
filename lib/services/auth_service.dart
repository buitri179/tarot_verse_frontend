
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_request.dart';
import '../models/auth_response.dart';
import '../config.dart';

class AuthService {
  final String _baseUrl = '$baseUrl/api/auth';

  // Helper để xử lý lỗi từ response
  Exception _handleError(http.Response response) {
    try {
      // Thử decode JSON từ body của response
      final errorBody = json.decode(response.body);
      // Lấy message lỗi, nếu không có thì trả về một message mặc định
      final errorMessage = errorBody['message'] ?? 'Đã có lỗi xảy ra. Vui lòng thử lại.';
      return Exception(errorMessage);
    } catch (e) {
      // Nếu không thể parse JSON, trả về lỗi chung
      return Exception('Không thể kết nối đến máy chủ. Vui lòng kiểm tra lại đường truyền.');
    }
  }

  Future<AuthResponse> register(RegistrationRequest request) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(request.toJson()),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final authResponse = AuthResponse.fromJson(json.decode(response.body));
      await _saveToken(authResponse.token);
      return authResponse;
    } else {
      throw _handleError(response);
    }
  }

  Future<AuthResponse> login(LoginRequest request) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(request.toJson()),
    );

    if (response.statusCode == 200) {
      final authResponse = AuthResponse.fromJson(json.decode(response.body));
      await _saveToken(authResponse.token);
      return authResponse;
    } else {
      throw _handleError(response);
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<String> getCurrentUser() async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Người dùng chưa đăng nhập');
    }
    final response = await http.get(
      Uri.parse('$_baseUrl/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw _handleError(response);
    }
  }
}

