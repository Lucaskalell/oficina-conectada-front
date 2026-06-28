import 'dart:convert';
import 'package:oficina_conectada_front/core/api/ApiClient.dart';
import 'package:oficina_conectada_front/models/cliente_carro_request_model.dart';
import 'package:oficina_conectada_front/models/cliente_model.dart';

class ClientesService {
  final ApiClient _apiClient = ApiClient();
  final String _base = '/clientes';

  Future<List<ClienteModel>> buscarClientes() async {
    final response = await _apiClient.get('$_base/com-carros');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((j) => ClienteModel.fromJson(j)).toList();
    }
    throw Exception('Falha ao carregar clientes: ${response.statusCode}');
  }

  Future<ClienteModel> criarClienteSimples(ClienteModel cliente) async {
    final response = await _apiClient.post(_base, body: cliente.toJson());
    if (response.statusCode == 200 || response.statusCode == 201) {
      return ClienteModel.fromJson(jsonDecode(response.body));
    }
    throw Exception('Falha ao criar cliente: ${response.statusCode}');
  }

  Future<ClienteModel> criarClienteComCarro(ClienteCarroRequestModel dto) async {
    final response = await _apiClient.post('$_base/completo', body: dto.toJson());
    if (response.statusCode == 200 || response.statusCode == 201) {
      return ClienteModel.fromJson(jsonDecode(response.body));
    }
    throw Exception('Falha ao criar cliente com veículo: ${response.statusCode}');
  }

  Future<void> deletarCliente(int id) async {
    final response = await _apiClient.delete('$_base/$id');
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Falha ao deletar cliente: ${response.statusCode}');
    }
  }
}
