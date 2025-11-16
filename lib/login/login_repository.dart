
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:oficina_conectada_front/common/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginRepository{

  Future<void>login(String email, String senha)async{
    final url = Uri.parse('${ApiConstants.baseUrl}/auth/login');

    try{
      final response= await http.post(
        url,
        headers:{
          'Content-type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'email': email,
          'senha': senha,
        }),
      );
      if(response.statusCode == 200){
        final data = json.decode(response.body);
        final String token = data['token'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', token);
      }else{
        throw Exception('Falha ao fazer login: ${response.statusCode}');
      }
    } catch(e, stackTrace) {
      debugPrint('Erro no LoginRepository: $e');
      debugPrint(stackTrace.toString());
      rethrow;
    }

  }
}