import 'dart:convert';
import 'package:oficina_conectada_front/core/api/ApiClient.dart';
import 'package:oficina_conectada_front/models/agendamento_model.dart';
import 'package:oficina_conectada_front/models/cliente_model.dart';
import 'package:oficina_conectada_front/models/mecanico_model.dart';

class AgendamentoService {
  final ApiClient _apiClient = ApiClient();
  final String _base = '/agendamentos';

  Future<List<AgendamentoModel>> buscarAgendamentos() async {
    final response = await _apiClient.get(_base);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((j) => AgendamentoModel.fromJson(j)).toList();
    }
    throw Exception('Falha ao carregar agendamentos: ${response.statusCode}');
  }

  Future<List<AgendamentoModel>> buscarAgendamentosPorPeriodo(DateTime inicio, DateTime fim) async {
    final inicioDia = DateTime(inicio.year, inicio.month, inicio.day).toIso8601String();
    final fimDia = DateTime(fim.year, fim.month, fim.day, 23, 59, 59).toIso8601String();
    final response = await _apiClient.get('$_base/periodo?inicio=$inicioDia&fim=$fimDia');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((j) => AgendamentoModel.fromJson(j)).toList();
    }
    throw Exception('Falha ao carregar agendamentos: ${response.statusCode}');
  }

  Future<List<ClienteModel>> buscarClientes() async {
    final response = await _apiClient.get('/clientes/com-carros');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((j) => ClienteModel.fromJson(j)).toList();
    }
    throw Exception('Falha ao carregar clientes: ${response.statusCode}');
  }

  Future<List<MecanicoModel>> buscarMecanicosAtivos() async {
    final response = await _apiClient.get('/mecanicos');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((j) => MecanicoModel.fromJson(j)).toList();
    }
    throw Exception('Falha ao carregar mecânicos: ${response.statusCode}');
  }

  Future<AgendamentoModel> criarAgendamento(AgendamentoModel agendamento) async {
    final response = await _apiClient.post(_base, body: agendamento.toJsonCriar());
    if (response.statusCode == 200 || response.statusCode == 201) {
      return AgendamentoModel.fromJson(jsonDecode(response.body));
    }
    throw Exception('Falha ao criar agendamento: ${response.statusCode}');
  }

  Future<void> atualizarStatus(int id, String status) async {
    final response = await _apiClient.patch('$_base/$id/status?status=$status');
    if (response.statusCode != 200) {
      throw Exception('Falha ao atualizar status: ${response.statusCode}');
    }
  }

  Future<void> deletarAgendamento(int id) async {
    final response = await _apiClient.delete('$_base/$id');
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Falha ao deletar agendamento: ${response.statusCode}');
    }
  }
}
