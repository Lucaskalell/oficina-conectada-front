import 'package:equatable/equatable.dart';
import 'package:oficina_conectada_front/models/categoria_resumo_model.dart';
import 'package:oficina_conectada_front/models/sub_categoria_model.dart';
import 'package:oficina_conectada_front/models/produto_model.dart';

enum NivelEstoque { categorias, subcategorias, produtos }

enum StatusEstoque { emEstoque, baixo, esgotado }

enum AcaoEstoque { nenhuma, produtoDeletado, produtoSalvo }

class EstoqueState extends Equatable {
  final NivelEstoque nivel;
  final bool carregando;
  final String? erro;
  final int totalItens;
  final int totalBaixo;
  final int totalPecasFisicas;
  final double valorTotalEstoque;
  final double valorTotalVenda;
  final List<CategoriaResumoModel> categorias;
  final int? catIdSelecionada;
  final String? catNomeSelecionada;
  final List<SubCategoriaModel> subcategorias;
  final int? subIdSelecionada;
  final String? subNomeSelecionada;
  final List<ProdutoModel> produtos;
  final String busca;
  final StatusEstoque? filtroStatus;
  final AcaoEstoque acao;

  const EstoqueState({
    this.nivel = NivelEstoque.categorias,
    this.carregando = false,
    this.erro,
    this.totalItens = 0,
    this.totalBaixo = 0,
    this.totalPecasFisicas = 0,
    this.valorTotalEstoque = 0.0,
    this.valorTotalVenda = 0.0,
    this.categorias = const [],
    this.catIdSelecionada,
    this.catNomeSelecionada,
    this.subcategorias = const [],
    this.subIdSelecionada,
    this.subNomeSelecionada,
    this.produtos = const [],
    this.busca = '',
    this.filtroStatus,
    this.acao = AcaoEstoque.nenhuma,
  });

  @override
  List<Object?> get props => [
    nivel, carregando, erro, totalItens, totalBaixo,
    totalPecasFisicas, valorTotalEstoque, valorTotalVenda,
    categorias, catIdSelecionada, catNomeSelecionada,
    subcategorias, subIdSelecionada, subNomeSelecionada,
    produtos, busca, filtroStatus, acao,
  ];
}
