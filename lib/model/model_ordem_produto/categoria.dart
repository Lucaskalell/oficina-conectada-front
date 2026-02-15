

class Categoria{
  final int id;
  final String nome;

  final List<dynamic>? subCategoria;

  Categoria({ required this.id,
    required this.nome,
    required this.subCategoria
  });

  factory Categoria.fromJson(Map<String, dynamic> json){
    return Categoria(
      id: json['id'] ?? 0,
      nome: json['nome'] ?? '',
      subCategoria: json['subCategoria']
    );
  }
}