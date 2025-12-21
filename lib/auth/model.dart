class SignInDTO {
  final String email;
  final String password;

  SignInDTO({required this.email, required this.password});

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

class SignUpDTO {
  final String email;
  final String password;

  SignUpDTO({required this.email, required this.password});

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

class AuthResponse {
  final String token;
  final int userId;

  AuthResponse({required this.token, required this.userId});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    try {
      return AuthResponse(
        token: json['token'],
        userId: json['userId'],
      );
    } catch (e) {
      throw Exception('Failed to parse AuthResponse: $e');
    }
  }
}