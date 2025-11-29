class CategoriaResumo {
  final int id;
  final int totalItens;
  final String nome;

  CategoriaResumo({required this.id, required this.totalItens, required this.nome});
  factory CategoriaResumo.fromJson(Map<String, dynamic> json) {
    return CategoriaResumo(
      id: json['id'] ?? 0,
      nome: json['nome'] ?? '',
      totalItens: (json['totalItens'] as num?)?.toInt() ?? 0,
    );
  }
}
