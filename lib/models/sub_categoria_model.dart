import 'categoria_model.dart';

class SubCategoriaModel {
  final int id;
  final String nome;
  final CategoriaModel? categoria;

  SubCategoriaModel({
    required this.id,
    required this.nome,
    this.categoria,
  });

  factory SubCategoriaModel.fromJson(Map<String, dynamic> json) {
    return SubCategoriaModel(
      id: json['id'],
      nome: json['nome'],
      categoria: json['categoria'] != null
          ? CategoriaModel.fromJson(json['categoria'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'categoria': categoria?.toJson(),
    };
  }
}
