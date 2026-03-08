import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:oficina_conectada_front/model/cliente_model.dart';

import '../core/api/ApiClient.dart';
import '../model/cliente_carro_request_model.dart';

class ClienteRepository {
  final ApiClient _apiClient = ApiClient();
  final String apiUrl = '/clientes';

  //busca todos os clientes cadastrados
  Future<List<ClienteModel>> getClientes() async {
    try {
      final response = await _apiClient.get('$apiUrl/simplesMasComCarro');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => ClienteModel.fromJson(json)).toList();
      } else {
        throw Exception('Falha ao carregar clientes:${response.statusCode}');
      }
    } catch (e, s) {
      debugPrint('Erro ao carregar clientes: $e,$s');
      rethrow;
    }
  }

  //criar cliente  simples (sem carro)
  Future<ClienteModel> criarClienteSimples(ClienteModel cliente) async {
    try {
      final response = await _apiClient.post(apiUrl, body: cliente.toJson());
      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return ClienteModel.fromJson(data);
      } else {
        throw Exception('Falha ao criar cliente: ${response.statusCode}');
      }
    } catch (e, s) {
      debugPrint('Erro ao criar cliente: $e,$s');
      rethrow;
    }
  }

  Future<ClienteModel> criarClienteComCarro(ClienteCarroRequestModel dto) async {
    try {
      final response = await _apiClient.post('$apiUrl/completo', body: dto.toJson());

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return ClienteModel.fromJson(data);
      } else {
        throw Exception('Falha ao criar cliente com veículo: ${response.statusCode}');
      }
    } catch (e, s) {
      debugPrint('Erro ao criar cliente com veículo: $e,$s');
      rethrow;
    }
  }

  Future<void> deletarCliente(int id) async {
    try {
      final response = await _apiClient.delete('$apiUrl/$id');
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Falha ao deletar cliente');
      }
    } catch (e, s) {
      debugPrint('Erro ao deletar cliente: $e,$s');
      rethrow;
    }
  }
}
