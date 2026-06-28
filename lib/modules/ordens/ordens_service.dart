import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:oficina_conectada_front/constants/api_constants.dart';
import 'package:oficina_conectada_front/core/api/ApiClient.dart';
import 'package:oficina_conectada_front/models/cliente_model.dart';
import 'package:oficina_conectada_front/modules/ordens/ordens_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrdensService {
  final ApiClient _apiClient = ApiClient();

  Future<List<OrdemDeServicoModel>> buscarOrdens() async {
    final resposta = await _apiClient.get('/ordens/resumo');
    if (resposta.statusCode == 200) {
      final List<dynamic> dados = jsonDecode(resposta.body);
      return dados.map((json) => OrdemDeServicoModel.fromJson(json)).toList();
    }
    throw Exception('Falha ao carregar ordens: ${resposta.statusCode}');
  }

  Future<OrdemDeServicoModel> buscarOrdemPorId(int id) async {
    final resposta = await _apiClient.get('/ordens/$id');
    if (resposta.statusCode == 200) {
      return OrdemDeServicoModel.fromJson(jsonDecode(resposta.body));
    }
    throw Exception('Falha ao buscar OS: ${resposta.statusCode}');
  }

  Future<void> deletarOrdem(int id) async {
    final resposta = await _apiClient.delete('/ordens/$id');
    if (resposta.statusCode != 200 && resposta.statusCode != 204) {
      throw Exception('Falha ao deletar OS: ${resposta.statusCode}');
    }
  }

  Future<List<ClienteModel>> buscarClientes() async {
    final resposta = await _apiClient.get('/clientes');
    if (resposta.statusCode == 200) {
      final List<dynamic> dados = jsonDecode(resposta.body);
      return dados.map((json) => ClienteModel.fromJson(json)).toList();
    }
    throw Exception('Falha ao carregar clientes');
  }

  Future<ClienteModel> buscarClienteCompleto(int id) async {
    final resposta = await _apiClient.get('/clientes/$id/completo');
    if (resposta.statusCode == 200) {
      return ClienteModel.fromJson(jsonDecode(resposta.body));
    }
    throw Exception('Falha ao carregar dados do cliente');
  }

  Future<OrdemDeServicoModel> criarOrdem(OrdemDeServicoModel ordem) async {
    final resposta = await _apiClient.post('/ordens/criar', body: ordem.toJson());
    if (resposta.statusCode == 200 || resposta.statusCode == 201) {
      return OrdemDeServicoModel.fromJson(jsonDecode(resposta.body));
    }
    throw Exception('Falha ao criar OS: ${resposta.statusCode}');
  }

  Future<ClienteModel> criarClienteComCarro(Map<String, dynamic> dados) async {
    final resposta = await _apiClient.post('/clientes/completo', body: dados);
    if (resposta.statusCode == 200 || resposta.statusCode == 201) {
      return ClienteModel.fromJson(jsonDecode(resposta.body));
    }
    throw Exception('Falha ao criar cliente e veículo');
  }

  Future<void> enviarFoto(int id, File foto) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/ordens/$id/fotos');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    final requisicao = http.MultipartRequest('POST', url);
    if (token != null) {
      requisicao.headers['Authorization'] = 'Bearer $token';
    }
    requisicao.files.add(await http.MultipartFile.fromPath('foto', foto.path));

    final streamedResponse = await requisicao.send();
    final resposta = await http.Response.fromStream(streamedResponse);

    if (resposta.statusCode != 200 && resposta.statusCode != 201) {
      debugPrint('Falha ao enviar foto: ${resposta.statusCode}');
      throw Exception('Falha ao enviar foto: ${resposta.statusCode}');
    }
  }
}
