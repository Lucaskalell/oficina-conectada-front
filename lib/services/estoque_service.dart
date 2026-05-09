import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:oficina_conectada_front/core/api/ApiClient.dart';
import 'package:oficina_conectada_front/models/categoria_model.dart';
import 'package:oficina_conectada_front/models/estoque_resumo_model.dart';

class EstoqueService {
  final ApiClient _apiClient = ApiClient();

  Future<List<CategoriaModel>> buscarCategorias() async {
    try {
      final response = await _apiClient.get('/estoque/categorias');
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => CategoriaModel.fromJson(json)).toList();
      } else {
        debugPrint('Erro ao buscar categorias: ${response.statusCode}');
        throw Exception('Falha ao carregar categorias do servidor');
      }
    } catch (e, stackTrace) {
      debugPrint('Erro de busca no EstoqueService: $e\n$stackTrace');
      rethrow;
    }
  }

  Future<EstoqueResumoModel> getResumoEstoque() async {
    try {
      final response = await _apiClient.get('/estoque/resumo');
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return EstoqueResumoModel.fromJson(data);
      } else {
        debugPrint('Erro ao buscar resumo do estoque: ${response.statusCode}');
        throw Exception('Falha ao carregar resumo do estoque do servidor');
      }
    } catch (e, s) {
      debugPrint('Erro de busca no EstoqueService: $e\n$s');
      rethrow;
    }
  }
}
