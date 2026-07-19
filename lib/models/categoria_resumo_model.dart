class CategoriaResumoModel {
  final int id;
  final int totalItens;
  final String nome;
  final int quantidadePecas;
  final double valorTotal;
  final double valorTotalVenda;

  CategoriaResumoModel({
    required this.id,
    required this.totalItens,
    required this.nome,
    required this.quantidadePecas,
    required this.valorTotal,
    required this.valorTotalVenda,
  });

  factory CategoriaResumoModel.fromJson(Map<String, dynamic> json) {
    return CategoriaResumoModel(
      id: json['id'] ?? 0,
      nome: json['nome'] ?? '',
      totalItens: (json['totalItens'] as num?)?.toInt() ?? 0,
      quantidadePecas: (json['quantidadePecas'] as num?)?.toInt() ?? 0,
      valorTotal: (json['valorTotal'] as num?)?.toDouble() ?? 0.0,
      valorTotalVenda: (json['valorTotalVenda'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'totalItens': totalItens,
      'quantidadePecas': quantidadePecas,
      'valorTotal': valorTotal,
      'valorTotalVenda': valorTotalVenda,
    };
  }
}
