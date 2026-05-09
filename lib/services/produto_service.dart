import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:oficina_conectada_front/core/api/ApiClient.dart';
import 'package:oficina_conectada_front/models/produto_model.dart';

class ProdutoService {
  final ApiClient _apiClient = ApiClient();

  Future<List<ProdutoModel>> buscarProdutos(int subCategoriaId) async {
    final String apiUrl = '/estoque/subCategorias/$subCategoriaId/produtos';
    try {
      final response = await _apiClient.get(apiUrl);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => ProdutoModel.fromJson(json)).toList();
      } else {
        throw Exception('Falha ao buscar produtos: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      debugPrint('Erro ao buscar produtos: $e, $stackTrace');
      rethrow;
    }
  }

  Future<void> criarProduto(ProdutoModel produto, int subCategoriaId) async {
    final String apiUrl = '/estoque/subcategorias/$subCategoriaId/produtos';
    try {
      final response = await _apiClient.post(apiUrl, body: produto.toJson());
      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception('Falha ao criar produto: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      debugPrint('Erro ao criar produto: $e, $stackTrace');
      rethrow;
    }
  }

  Future<void> atualizarProduto(ProdutoModel produto, int subCategoriaId) async {
    final String apiUrl = '/estoque/produtos/${produto.id}';
    try {
      final response = await _apiClient.put(apiUrl, body: produto.toJson());
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Falha ao atualizar produto: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Erro ao atualizar produto: $e');
      rethrow;
    }
  }

  Future<void> deletarProduto(int produtoId, int subCategoriaId) async {
    final String apiUrl = '/estoque/produtos/$produtoId';
    try {
      final response = await _apiClient.delete(apiUrl);
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Falha ao deletar produto: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Erro ao deletar produto: $e');
      rethrow;
    }
  }
}
