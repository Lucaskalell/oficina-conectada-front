import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:oficina_conectada_front/core/api/ApiClient.dart';

import '../model/model_dash_board/dash_board_model.dart';

class DashBoardRepository {
  final ApiClient _apiClient = ApiClient();

  Future<DashboardModel> getDashboardData() async {
    try {
      final response = await _apiClient.get('/dashboard/resumo');
      if (response.statusCode == 200) {
        return DashboardModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Falha ao carregar dados do dashboard:${response.statusCode}');
      }
    }catch(e,s){
      debugPrint('Erro ao carregar dados do dashboard: $e,$s');
      rethrow;
    }
  }
}
