
import 'categoria.dart';

class SubCategoria {
  final int id;
  final String nome;
  final Categoria? categoria;

  SubCategoria({
    required this.id,
    required this.nome,
    this.categoria,
  });

  factory SubCategoria.fromJson(Map<String, dynamic> json) {
    return SubCategoria(
      id: json['id'],
      nome: json['nome'],
      categoria: json['categoria'] != null
          ? Categoria.fromJson(json['categoria'])
          : null,
    );
  }
}