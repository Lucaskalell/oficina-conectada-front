
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:oficina_conectada_front/common/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient{
  final http.Client _client;
  ApiClient(): _client = http.Client();

  Future<Map<String, String>> _getAuthHeaders() async{
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if(token == null){
      return{
        'Content-Type': 'application/json; charset=UTF-8'
      };
    }
    return{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token'
    };
  }
  
  Future<http.Response> get(String endPoint) async{
    final url = Uri.parse('${ApiConstants.baseUrl}$endPoint');
    final headers = await _getAuthHeaders();
    return _client.get(url, headers: headers);
  }
  
  Future<http.Response>post(String endPoint, {dynamic body})async{
    final url = Uri.parse('${ApiConstants.baseUrl}$endPoint');
    final headers = await _getAuthHeaders();
    final jsonBody = jsonEncode(body);
    return _client.post(url, headers: headers, body: jsonBody);
  }
  
  Future<http.Response>put(String endPoint, {dynamic body})async{
    final url = Uri.parse('${ApiConstants.baseUrl}$endPoint');
    final headers = await _getAuthHeaders();
    final jsonBody = jsonEncode(body);
    return _client.put(url, headers: headers, body: jsonBody);
  }
  
  Future<http.Response>delete(String endPoint)async{
    final url = Uri.parse('${ApiConstants.baseUrl}$endPoint');
    final headers = await _getAuthHeaders();
    return _client.delete(url, headers: headers);
  }
}