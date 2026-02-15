class Produto {
  final int id;
  final String nome;
  final String? descricao;
  final double precoCusto;
  final double precoVenda;
  final int quantidadeEmEstoque;

  Produto({
    required this.id,
    required this.nome,
    this.descricao,
    required this.precoCusto,
    required this.precoVenda,
    required this.quantidadeEmEstoque,
  });

  factory Produto.fromJson(Map<String, dynamic> json) {
    return Produto(
      id: json['id'] ?? 0,
      nome: json['nome'] ?? '',
      descricao: json['descricao'],
      precoCusto: (json['precoCusto'] as num?)?.toDouble() ?? 0.0,
      precoVenda: (json['precoVenda'] as num?)?.toDouble() ?? 0.0,
      quantidadeEmEstoque: (json['quantidadeEmEstoque'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String,dynamic>toJson(){
    return{
      'nome': nome,
      'descricao': descricao,
      'precoCusto': precoCusto,
      'precoVenda': precoVenda,
      'quantidadeEmEstoque': quantidadeEmEstoque,
    };
  }
}
