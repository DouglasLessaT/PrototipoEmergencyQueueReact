import 'dart:convert';
import 'package:http/http.dart' as http;

class LoginService {
  static const String baseUrl = 'http://localhost:8081/EmergencyApi';

  // Modelo para resposta de login
  static Map<String, dynamic>? _userData;

  // Getters para acessar dados do usuário logado
  static Map<String, dynamic>? get userData => _userData;
  static bool get isLoggedIn => _userData != null;
  static String? get userToken => _userData?['token'];
  static String? get userType => _userData?['userType'];

  // Método para fazer login com múltiplas tentativas
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    required String userType,
  }) async {
    // Tentativa 1: POST com JSON
    var result = await _tryPostLogin(email, password, userType);
    if (result['success']) return result;

    // Tentativa 2: POST com form data
    result = await _tryPostFormLogin(email, password, userType);
    if (result['success']) return result;

    // Tentativa 3: GET com query parameters
    result = await _tryGetLogin(email, password, userType);
    if (result['success']) return result;

    // Se todas falharem, retorna o último erro
    return result;
  }

  // Tentativa com POST e form params (formato esperado pelo backend)
  static Future<Map<String, dynamic>> _tryPostLogin(
    String email,
    String password,
    String userType,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: 'login=${Uri.encodeComponent(email)}&senha=${Uri.encodeComponent(password)}',
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _userData = {
          'token': data['token'] ?? '',
          'userType': userType,
          'email': email,
          'userData': data,
        };

        return {
          'success': true,
          'message': 'Login realizado com sucesso',
          'data': data,
        };
      }
    } catch (e) {
      // ignorado, tenta próximo método
    }

    return {'success': false, 'message': 'POST form falhou'};
  }

  // Tentativa com POST e form data
  static Future<Map<String, dynamic>> _tryPostFormLogin(
    String email,
    String password,
    String userType,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'login': email, 'senha': password},
      );

      print('POST Form Response status: ${response.statusCode}');
      print('POST Form Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _userData = {
          'token': data['token'] ?? '',
          'userType': userType,
          'email': email,
          'userData': data,
        };

        return {
          'success': true,
          'message': 'Login realizado com sucesso',
          'data': data,
        };
      }
    } catch (e) {
      print('POST Form error: $e');
    }

    return {'success': false, 'message': 'POST Form falhou'};
  }

  // Tentativa com GET
  static Future<Map<String, dynamic>> _tryGetLogin(
    String email,
    String password,
    String userType,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/login?login=$email&senha=$password'),
        headers: {'Content-Type': 'application/json'},
      );

      print('GET Response status: ${response.statusCode}');
      print('GET Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _userData = {
          'token': data['token'] ?? '',
          'userType': userType,
          'email': email,
          'userData': data,
        };

        return {
          'success': true,
          'message': 'Login realizado com sucesso',
          'data': data,
        };
      } else if (response.statusCode == 401) {
        return {'success': false, 'message': 'Credenciais inválidas'};
      } else {
        return {
          'success': false,
          'message': 'Erro no servidor: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('GET error: $e');
      return {'success': false, 'message': 'Erro de conexão: $e'};
    }
  }

  // Método para fazer logout
  static void logout() {
    _userData = null;
  }

  // Método para verificar se o token ainda é válido
  static Future<bool> validateToken() async {
    if (_userData == null || _userData!['token'] == null) {
      return false;
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/validate'),
        headers: {
          'Authorization': 'Bearer ${_userData!['token']}',
          'Content-Type': 'application/json',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
