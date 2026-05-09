class CategoriaModel {
  final int id;
  final String nome;
  final List<dynamic>? subCategoria;

  CategoriaModel({
    required this.id,
    required this.nome,
    this.subCategoria,
  });

  factory CategoriaModel.fromJson(Map<String, dynamic> json) {
    return CategoriaModel(
      id: json['id'] ?? 0,
      nome: json['nome'] ?? '',
      subCategoria: json['subCategoria'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'subCategoria': subCategoria,
    };
  }
}
