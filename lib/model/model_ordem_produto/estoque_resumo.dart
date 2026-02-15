import 'CategoriaResumo.dart';

class EstoqueResumo {
  final int totalPecasCadastradas;
  final String itemMaisVendido;
  final int itensBaixoEstoque;
  final List<CategoriaResumo> categorias;

  EstoqueResumo({
    required this.totalPecasCadastradas,
    required this.itemMaisVendido,
    required this.itensBaixoEstoque,
    required this.categorias,
  });

  factory EstoqueResumo.fromJson(Map<String, dynamic> json) {
    return EstoqueResumo(
      totalPecasCadastradas: (json['totalPecasCadastradas'] as num?)?.toInt() ?? 0,
      itemMaisVendido: json['itemMaisVendido'] ?? 'Nenhum',
      itensBaixoEstoque: (json['itensBaixoEstoque'] as num?)?.toInt() ?? 0,
      categorias: (json['categorias'] as List?)?.map((e) => CategoriaResumo.fromJson(e)).toList() ?? [],
    );
  }
}
