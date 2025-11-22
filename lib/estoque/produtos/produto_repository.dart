import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:oficina_conectada_front/core/api/ApiClient.dart';
import 'package:oficina_conectada_front/estoque/model/produto.dart';

class ProdutoRepository {
  final ApiClient _apiClient = ApiClient();

  Future<List<Produto>> buscarProdutos(int subCategoriaId) async {
    final String apiUrl = '/estoque/subCategorias/$subCategoriaId/produtos';
    try {
      final response = await _apiClient.get(apiUrl);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Produto.fromJson(json)).toList();
      } else {
        throw Exception('Falha ao buscar produtos:${response.statusCode}');
      }
    } catch (e, stackTrace) {
      debugPrint('deu erro :$e');
      debugPrint('segue o erro :$stackTrace');
      rethrow;
    }
  }

  Future<void> criarProduto(Produto produto, int subCategoriaId) async {
    final String apiUrl = '/estoque/subCategorias/$subCategoriaId/produtos';
    try {
      final response = await _apiClient.post(
        apiUrl,
        body: produto.toJson(),
      );
      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception('Falha ao criar produto: ${response.statusCode} - ${response.body}');
      }
    } catch (e, stackTrace) {
      debugPrint('Erro no POST: $e');
      debugPrint('Stack Trace: $stackTrace');
      rethrow;
    }
  }
}
