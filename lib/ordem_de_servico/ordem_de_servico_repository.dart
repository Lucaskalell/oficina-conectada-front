import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:oficina_conectada_front/core/api/ApiClient.dart';
import 'package:oficina_conectada_front/model/add_ordem_de_servico/ordem_de_servico_model.dart';
import 'package:oficina_conectada_front/model/cliente_model.dart';
import 'package:oficina_conectada_front/model/carro_model.dart';

class OrdemDeServicoRepository {
  final ApiClient _apiClient = ApiClient();


  Future<List<ClienteModel>> getClientes() async {
    const String apiUrl = '/clientes';
    try {
      final response = await _apiClient.get(apiUrl);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => ClienteModel.fromJson(json)).toList();
      } else {
        throw Exception('Falha ao carregar clientes');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<ClienteModel> getClienteCompleto(int id) async {
    final String apiUrl = '/clientes/$id/completo'; 
    try {
      final response = await _apiClient.get(apiUrl);
      if (response.statusCode == 200) {
        return ClienteModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Falha ao carregar dados completos do cliente');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<OrdemDeServicoModel> postOrdenDeServico(OrdemDeServicoModel ordemDeServico) async {
    const String apiUrl = '/ordens/criarOrdemDeServico'; 
    try {
      final response = await _apiClient.post(apiUrl, body: ordemDeServico.toJson());
      if (response.statusCode == 200 || response.statusCode == 201) {
        return OrdemDeServicoModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Falha ao criar Ordem de serviço: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<ClienteModel> postClienteComCarroNovo(Map<String, dynamic> clienteCarroData) async {
    const String apiUrl = '/clientes/completo';
    try{
      final response = await _apiClient.post(apiUrl, body: clienteCarroData);
      if(response.statusCode == 201|| response.statusCode == 200){
        return ClienteModel.fromJson(jsonDecode(response.body));
      }else{
        throw Exception('Falaha ao criar cliente e veiculo');
      }
    }catch(e,s){
      debugPrint('Erro ao criar cliente e veiculo : $e,$s');
      rethrow;
    }
  }

  // --- Metodos padroes  da os  (LISTAGEM, EDIÇÃO, EXCLUSÃO) ---

  Future<List<OrdemDeServicoModel>> getOrdensDeServico() async {
    const String apiUrl = '/ordens/resumo';
    try {
      final response = await _apiClient.get(apiUrl);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => OrdemDeServicoModel.fromJson(json)).toList();
      } else {
        throw Exception('Falha ao carregar ordens de serviço');
      }
    } catch (e) {
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
        throw Exception('Falha ao buscar OS: ${response.statusCode}');
      }
    } catch (e) {
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
        throw Exception('Falha ao atualizar OS: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deletarOrdenDeServico(int id) async {
    final String apiUrl = '/ordens/$id';
    try {
      final response = await _apiClient.delete(apiUrl);
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Falha ao deletar OS: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
