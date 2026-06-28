import 'dart:convert';
import 'package:oficina_conectada_front/core/api/ApiClient.dart';
import 'package:oficina_conectada_front/models/carro_model.dart';

class VeiculosService {
  final ApiClient _apiClient = ApiClient();
  final String _base = '/carros';

  Future<List<CarroStatusModel>> buscarVeiculosComStatus() async {
    final response = await _apiClient.get('$_base/status');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((j) => CarroStatusModel.fromJson(j)).toList();
    }
    throw Exception('Falha ao carregar veículos: ${response.statusCode}');
  }

  Future<CarroModel> criarVeiculo(CarroModel carro) async {
    final response = await _apiClient.post(_base, body: carro.toJson());
    if (response.statusCode == 200 || response.statusCode == 201) {
      return CarroModel.fromJson(jsonDecode(response.body));
    }
    throw Exception('Falha ao cadastrar veículo: ${response.statusCode}');
  }

  Future<void> deletarVeiculo(int id) async {
    final response = await _apiClient.delete('$_base/$id');
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Falha ao excluir veículo: ${response.statusCode}');
    }
  }
}
