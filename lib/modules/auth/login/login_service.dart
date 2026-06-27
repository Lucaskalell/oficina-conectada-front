import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:oficina_conectada_front/core/constants/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginService {
  final FlutterSecureStorage _secureStorage;

  LoginService(this._secureStorage);

  Future<void> realizarLogin(String email, String senha) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/auth/login');

    final resposta = await http.post(
      url,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'email': email, 'senha': senha}),
    );

    if (resposta.statusCode == 200) {
      final dados = json.decode(resposta.body);
      final String token = dados['token'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_token', token);
    } else {
      throw Exception('Credenciais inválidas');
    }
  }

  Future<void> salvarCredenciais(String email, String senha) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lembrar_email', email);
    await prefs.setBool('lembrar_me', true);
    await _secureStorage.write(key: 'lembrar_senha', value: senha);
  }

  Future<void> removerCredenciais() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('lembrar_email');
    await prefs.setBool('lembrar_me', false);
    await _secureStorage.delete(key: 'lembrar_senha');
  }

  Future<Map<String, String?>> carregarCredenciais() async {
    final prefs = await SharedPreferences.getInstance();
    final lembrarMe = prefs.getBool('lembrar_me') ?? false;

    if (!lembrarMe) return {'email': null, 'senha': null, 'lembrarMe': 'false'};

    final email = prefs.getString('lembrar_email');
    final senha = await _secureStorage.read(key: 'lembrar_senha');

    return {'email': email, 'senha': senha, 'lembrarMe': 'true'};
  }

  Future<void> realizarLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    debugPrint('Logout realizado');
  }
}
