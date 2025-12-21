import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:oficina_conectada_front/core/api/ApiClient.dart';

import 'model/ordem_de_servico_model.dart';

mixin class OrdemDeServicoRepository {
  final ApiClient _apiClient = ApiClient();

  Future<List<OrdemDeServicoModel>> getOrdensDeServico() async {
    const String apiUrl = '/ordens/resumo';
    try {
      final response = await _apiClient.get(apiUrl);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => OrdemDeServicoModel.fromJson(json)).toList();
      } else {
        throw Exception('Falha ao carregar ordens de serviço: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('deu erro: $e');
      rethrow;
    }
  }

  Future<OrdemDeServicoModel> getOrdenDeServicoById(int id) async {
    final String apiUrl = '/ordens/$id';
    try {
      final response = await _apiClient.get(apiUrl);
      if (response.statusCode == 200) {
        return OrdemDeServicoModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Falha ao carregar ordens de serviço por id:${response.statusCode}');
      }
    } catch (e) {
      debugPrint('deu erro: $e');
      rethrow;
    }
  }

  Future<OrdemDeServicoModel> putOrdenDeServico(OrdemDeServicoModel ordemDeServico) async {
    final String apiUrl = '/ordens/${ordemDeServico.id}';
    try {
      final response = await _apiClient.put(apiUrl, body: ordemDeServico.toJson());
      if (response.statusCode == 200) {
        return OrdemDeServicoModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Falha ao criar dados da Ordem de servico:${response.statusCode}');
      }
    } catch (e) {
      debugPrint('deu erro: $e');
      rethrow;
    }
  }

  Future<OrdemDeServicoModel> postOrdenDeServico(OrdemDeServicoModel ordemDeServico) async {
    const String apiUrl = '/ordens/';
    try {
      final response = await _apiClient.post(apiUrl, body: ordemDeServico.toJson());
      if (response.statusCode == 200) {
        return OrdemDeServicoModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Falha ao atualizar dados da Ordem de servico:${response.statusCode}');
      }
    } catch (e) {
      debugPrint('deu erro: $e');
      rethrow;
    }
  }

  Future<void> deletarOrdenDeServico(int id) async {
    final String apiUrl = '/ordens/$id';
    try {
      final response = await _apiClient.delete(apiUrl);
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Falha ao deletar ordem de serviço: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('deu erro: $e');
      rethrow;
    }
  }
}
