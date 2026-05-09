import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:oficina_conectada_front/constants/api_constants.dart';
import 'package:oficina_conectada_front/core/api/ApiClient.dart';
import 'package:oficina_conectada_front/models/ordem_de_servico_model.dart';
import 'package:oficina_conectada_front/models/cliente_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrdemDeServicoService {
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

  Future<OrdemDeServicoModel> postOrdemDeServico(
    OrdemDeServicoModel ordemDeServico,
  ) async {
    const String apiUrl = '/ordens/criar';
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

  Future<ClienteModel> postClienteComCarroNovo(
    Map<String, dynamic> clienteCarroData,
  ) async {
    const String apiUrl = '/clientes/completo';
    try {
      final response = await _apiClient.post(apiUrl, body: clienteCarroData);
      if (response.statusCode == 201 || response.statusCode == 200) {
        return ClienteModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Falha ao criar cliente e veiculo');
      }
    } catch (e, s) {
      debugPrint('Erro ao criar cliente e veiculo : $e, $s');
      rethrow;
    }
  }

  Future<void> enviarFoto(int id, File foto) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/ordens/$id/fotos');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    try {
      final request = http.MultipartRequest('POST', url);
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.files.add(await http.MultipartFile.fromPath('foto', foto.path));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Falha ao enviar foto: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Erro ao enviar foto: $e');
      rethrow;
    }
  }

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

  Future<OrdemDeServicoModel> getOrdemDeServicoById(int id) async {
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

  Future<OrdemDeServicoModel> putOrdemDeServico(
    OrdemDeServicoModel ordemDeServico,
  ) async {
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

  Future<void> deletarOrdemDeServico(int id) async {
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
