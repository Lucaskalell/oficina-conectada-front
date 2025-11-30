import 'dart:convert';

import 'package:oficina_conectada_front/core/api/ApiClient.dart';
import 'package:oficina_conectada_front/dash_board/model/dash_board_model.dart';

class DashBoardRepository{
  final ApiClient _apiClient = ApiClient();

  Future<DashboardData>getDashboardData() async {
    final response = await _apiClient.get('/dashboard/resumo');
    if(response.statusCode == 200){
      return DashboardData.fromJson(jsonDecode(response.body));
    }else{
      throw Exception('Falha ao carregar dados do dashboard:${response.statusCode}');
    }
  }
}