import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:oficina_conectada_front/core/api/ApiClient.dart';
import 'package:oficina_conectada_front/estoque/model/sub_categoria.dart';

class SubCategoriaRepository {
  final ApiClient _apiClient = ApiClient();

  Future<List<SubCategoria>> buscarSubCategorias(int categoriaId) async {
    try {
      final response = await _apiClient.get('/estoque/categorias/$categoriaId/subCategorias');
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => SubCategoria.fromJson(json)).toList();
      } else {
        debugPrint('Erro ao buscar sub categorias: ${response.statusCode}');
        throw Exception('Erro ao buscar sub categorias');
      }
    } catch (e, stackTrace) {
      debugPrint('$e\n$stackTrace');
      rethrow;
    }
  }
}
