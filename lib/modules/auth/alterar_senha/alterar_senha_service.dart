import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:oficina_conectada_front/core/constants/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AlterarSenhaService {
  Future<void> alterarSenha(String novaSenha) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token') ?? '';

    final resposta = await http.put(
      Uri.parse('${ApiConstants.baseUrl}/auth/alterar-senha'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'novaSenha': novaSenha}),
    );

    if (resposta.statusCode != 204) {
      throw Exception('Falha ao alterar senha');
    }
  }
}
