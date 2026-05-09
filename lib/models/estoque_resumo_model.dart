import 'categoria_resumo_model.dart';

class EstoqueResumoModel {
  final int totalPecasCadastradas;
  final String itemMaisVendido;
  final int itensBaixoEstoque;
  final List<CategoriaResumoModel> categorias;

  EstoqueResumoModel({
    required this.totalPecasCadastradas,
    required this.itemMaisVendido,
    required this.itensBaixoEstoque,
    required this.categorias,
  });

  factory EstoqueResumoModel.fromJson(Map<String, dynamic> json) {
    return EstoqueResumoModel(
      totalPecasCadastradas: (json['totalPecasCadastradas'] as num?)?.toInt() ?? 0,
      itemMaisVendido: json['itemMaisVendido'] ?? 'Nenhum',
      itensBaixoEstoque: (json['itensBaixoEstoque'] as num?)?.toInt() ?? 0,
      categorias:
          (json['categorias'] as List?)
              ?.map((e) => CategoriaResumoModel.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalPecasCadastradas': totalPecasCadastradas,
      'itemMaisVendido': itemMaisVendido,
      'itensBaixoEstoque': itensBaixoEstoque,
      'categorias': categorias.map((e) => e.toJson()).toList(),
    };
  }
}
