
class ItemServicoModel {
  final int? id;
  final String descricao;
  final double quantidade;
  final double valorUnitario;
  final double valorTotal;

  ItemServicoModel({
    this.id,
    required this.descricao,
    required this.quantidade,
    required this.valorUnitario,
    required this.valorTotal,
  });

  factory ItemServicoModel.fromJson(Map<String, dynamic> json) {
    return ItemServicoModel(
      id: json['id'],
      descricao: json['descricao'] ?? '',
      quantidade: (json['quantidade'] ?? 0.0).toDouble(),
      valorUnitario: (json['valorUnitario'] ?? 0.0).toDouble(),
      valorTotal: (json['valorTotal'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'descricao': descricao,
      'quantidade': quantidade,
      'valorUnitario': valorUnitario,
      'valorTotal': valorTotal,
    };
  }
}
