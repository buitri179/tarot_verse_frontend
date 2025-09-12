// auth_request.dart

// Dùng cho yêu cầu đăng ký
class RegistrationRequest {
  final String name;
  final String email;
  final String password;

  RegistrationRequest({
    required this.name,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'password': password,
    };
  }
}

// Dùng cho yêu cầu đăng nhập
class LoginRequest {
  final String email;
  final String password;

  LoginRequest({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}
