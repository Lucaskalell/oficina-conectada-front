import 'dart:convert';
import 'package:oficina_conectada_front/core/api/ApiClient.dart';
import 'package:oficina_conectada_front/models/mecanico_model.dart';

class MecanicosService {
  final ApiClient _apiClient = ApiClient();
  final String _base = '/mecanicos';

  Future<List<MecanicoModel>> buscarMecanicos() async {
    final response = await _apiClient.get('$_base/todos');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((j) => MecanicoModel.fromJson(j)).toList();
    }
    throw Exception('Falha ao carregar mecânicos: ${response.statusCode}');
  }

  Future<MecanicoModel> criarMecanico(MecanicoModel mecanico) async {
    final response = await _apiClient.post(_base, body: mecanico.toJsonCriar());
    if (response.statusCode == 200 || response.statusCode == 201) {
      return MecanicoModel.fromJson(jsonDecode(response.body));
    }
    throw Exception('Falha ao criar mecânico: ${response.statusCode}');
  }

  Future<MecanicoModel> atualizarMecanico(int id, MecanicoModel dados) async {
    final response = await _apiClient.put('$_base/$id', body: dados.toJsonAtualizar());
    if (response.statusCode == 200) {
      return MecanicoModel.fromJson(jsonDecode(response.body));
    }
    throw Exception('Falha ao atualizar mecânico: ${response.statusCode}');
  }

  Future<void> desativarMecanico(int id) async {
    final response = await _apiClient.delete('$_base/$id');
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Falha ao desativar mecânico: ${response.statusCode}');
    }
  }
}
