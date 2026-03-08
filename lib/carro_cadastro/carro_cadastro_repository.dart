import 'dart:convert';
import 'package:oficina_conectada_front/core/api/ApiClient.dart';
import 'package:oficina_conectada_front/model/carro_model.dart';

class CarroRepository {
  final ApiClient _apiClient = ApiClient();
  final String apiUrl = '/carros';

  Future<List<CarroStatusModel>> getCarrosComStatus() async {
    try {
      final response = await _apiClient.get('$apiUrl/status');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => CarroStatusModel.fromJson(json)).toList();
      } else {
        throw Exception('Falha ao carregar veículos com status: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }


  Future<List<CarroModel>> getCarros() async {
    try {
      final response = await _apiClient.get(apiUrl);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => CarroModel.fromJson(json)).toList();
      } else {
        throw Exception('Falha ao carregar veículos: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<CarroModel> criarCarro(CarroModel carro) async {
    try {
      final response = await _apiClient.post(apiUrl, body: carro.toJson());

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return CarroModel.fromJson(data);
      } else {
        throw Exception('Falha ao cadastrar veículo: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<CarroModel> atualizarCarro(int id, CarroModel carro) async {
    try {
      final response = await _apiClient.put('$apiUrl/$id', body: carro.toJson());

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return CarroModel.fromJson(data);
      } else {
        throw Exception('Falha ao atualizar veículo: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deletarCarro(int id) async {
    try {
      final response = await _apiClient.delete('$apiUrl/$id');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Falha ao excluir veículo: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
