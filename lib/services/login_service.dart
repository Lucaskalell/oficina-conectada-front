import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:oficina_conectada_front/constants/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginService {
  Future<void> login(String email, String senha) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/auth/login');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'email': email,
          'senha': senha,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final String token = data['token'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', token);
      } else {
        throw Exception('Falha ao fazer login: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      debugPrint('Erro no LoginService: $e');
      debugPrint(stackTrace.toString());
      rethrow;
    }
  }

  Future<void> registrar(String nome, String email, String senha) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/auth/registrar');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'nome': nome,
          'email': email,
          'senha': senha,
        }),
      );

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception('Falha ao registrar: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Erro no LoginService ao registrar: $e');
      rethrow;
    }
  }
}
