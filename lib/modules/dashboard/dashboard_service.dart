import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:oficina_conectada_front/core/api/ApiClient.dart';
import 'package:oficina_conectada_front/modules/dashboard/dashboard_model.dart';

class DashboardService {
  final ApiClient _apiClient = ApiClient();

  Future<DashboardModel> buscarDados() async {
    try {
      final resposta = await _apiClient.get('/dashboard/resumo');
      if (resposta.statusCode == 200) {
        return DashboardModel.fromJson(jsonDecode(resposta.body));
      } else {
        throw Exception('Falha ao carregar dados do dashboard: ${resposta.statusCode}');
      }
    } catch (e, s) {
      debugPrint('Erro ao carregar dashboard: $e\n$s');
      rethrow;
    }
  }
}
