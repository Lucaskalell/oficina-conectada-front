import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:oficina_conectada_front/core/api/ApiClient.dart';
import 'package:oficina_conectada_front/model/add_ordem_de_servico/ordem_de_servico_model.dart';
import 'package:oficina_conectada_front/model/cliente_model.dart';

class OrdemDeServicoRepository {
  final ApiClient _apiClient = ApiClient();

  // Buscar clientes para o Dropdown na criação de OS
  Future<List<ClienteModel>> getClientes() async {
    const String apiUrl = '/clientes';
    try {
      final response = await _apiClient.get(apiUrl);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => ClienteModel.fromJson(json)).toList();
      } else {
        throw Exception('Falha ao carregar clientes: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Erro ao buscar clientes: $e');
      rethrow;
    }
  }

  // Listagem resumida (para a tela principal)
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
      debugPrint('Erro ao carregar ordens: $e');
      rethrow;
    }
  }

  // Buscar uma OS específica por ID
  Future<OrdemDeServicoModel> getOrdenDeServicoById(int id) async {
    final String apiUrl = '/ordens/$id';
    try {
      final response = await _apiClient.get(apiUrl);
      if (response.statusCode == 200) {
        return OrdemDeServicoModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Falha ao carregar OS por id: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Erro ao buscar OS por id: $e');
      rethrow;
    }
  }

  // Atualizar Ordem de Serviço (PUT)
  Future<OrdemDeServicoModel> putOrdenDeServico(OrdemDeServicoModel ordemDeServico) async {
    final String apiUrl = '/ordens/${ordemDeServico.id}';
    try {
      final response = await _apiClient.put(apiUrl, body: ordemDeServico.toJson());
      if (response.statusCode == 200) {
        return OrdemDeServicoModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Falha ao atualizar Ordem de serviço: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Erro ao atualizar OS: $e');
      rethrow;
    }
  }

  // Criar Nova Ordem de Serviço (POST)
  Future<OrdemDeServicoModel> postOrdenDeServico(OrdemDeServicoModel ordemDeServico) async {
    const String apiUrl = '/ordens/criarOrdemDeServico'; 
    try {
      final response = await _apiClient.post(apiUrl, body: ordemDeServico.toJson());
      
      // O backend retorna 201 (Created) para criações
      if (response.statusCode == 200 || response.statusCode == 201) {
        return OrdemDeServicoModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Falha ao criar Ordem de serviço: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Erro ao criar OS: $e');
      rethrow;
    }
  }

  // Deletar Ordem de Serviço
  Future<void> deletarOrdenDeServico(int id) async {
    final String apiUrl = '/ordens/$id';
    try {
      final response = await _apiClient.delete(apiUrl);
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Falha ao deletar ordem de serviço: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Erro ao deletar OS: $e');
      rethrow;
    }
  }
}
