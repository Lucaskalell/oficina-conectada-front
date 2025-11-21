
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:oficina_conectada_front/core/api/ApiClient.dart';

import 'model/categoria.dart';

class EstoqueRepository{
  final ApiClient _apiClient = ApiClient();


  Future<List<Categoria>> buscarCategorias()async{
    try{
      final response = await _apiClient.get('/estoque/categorias');
      if(response.statusCode == 200){
        final List<dynamic>jsonList = jsonDecode(response.body);
        return jsonList.map((json) => Categoria.fromJson(json)).toList();
      }else{
        debugPrint('Erro ao buscar categorias: ${response.statusCode}');
        throw Exception('Falha ao carregar categorias do servidor');
      }
    }catch(e,stackTrace){
      debugPrint('Erro de busca no EstoqueRepostiory: $e\n$stackTrace');
      rethrow;
    }
  }

}