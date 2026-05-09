class CategoriaResumoModel {
  final int id;
  final int totalItens;
  final String nome;

  CategoriaResumoModel({
    required this.id,
    required this.totalItens,
    required this.nome,
  });

  factory CategoriaResumoModel.fromJson(Map<String, dynamic> json) {
    return CategoriaResumoModel(
      id: json['id'] ?? 0,
      nome: json['nome'] ?? '',
      totalItens: (json['totalItens'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'totalItens': totalItens,
    };
  }
}
