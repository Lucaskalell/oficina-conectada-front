import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oficina_conectada_front/modules/estoque/estoque_event.dart';
import 'package:oficina_conectada_front/modules/estoque/estoque_service.dart';
import 'package:oficina_conectada_front/modules/estoque/estoque_state.dart';

class EstoqueBloc extends Bloc<EstoqueEvent, EstoqueState> {
  final EstoqueService _service;

  EstoqueBloc(this._service) : super(const EstoqueState()) {
    on<EstoqueCarregado>(_onCarregado);
    on<CategoriaSelecionada>(_onCategoriaSelecionada);
    on<SubcategoriaSelecionada>(_onSubcategoriaSelecionada);
    on<BreadcrumbTocado>(_onBreadcrumbTocado);
    on<BuscaAlterada>(_onBuscaAlterada);
    on<FiltroStatusAlterado>(_onFiltroStatusAlterado);
    on<ProdutoExcluido>(_onProdutoExcluido);
    on<ProdutoSalvo>(_onProdutoSalvo);
  }

  Future<void> _onCarregado(EstoqueCarregado evento, Emitter<EstoqueState> emit) async {
    emit(const EstoqueState(carregando: true));
    try {
      final resumo = await _service.buscarResumo();
      emit(EstoqueState(
        nivel: NivelEstoque.categorias,
        totalItens: resumo.totalPecasCadastradas,
        totalBaixo: resumo.itensBaixoEstoque,
        totalPecasFisicas: resumo.totalPecasFisicas,
        valorTotalEstoque: resumo.valorTotalEstoque,
        valorTotalVenda: resumo.valorTotalVenda,
        categorias: resumo.categorias,
      ));
    } catch (e) {
      emit(EstoqueState(erro: e.toString()));
    }
  }

  Future<void> _onCategoriaSelecionada(CategoriaSelecionada evento, Emitter<EstoqueState> emit) async {
    emit(EstoqueState(
      carregando: true,
      totalItens: state.totalItens,
      totalBaixo: state.totalBaixo,
      totalPecasFisicas: state.totalPecasFisicas,
      valorTotalEstoque: state.valorTotalEstoque,
      valorTotalVenda: state.valorTotalVenda,
      categorias: state.categorias,
    ));
    try {
      final subcategorias = await _service.buscarSubcategorias(evento.catId);
      emit(EstoqueState(
        nivel: NivelEstoque.subcategorias,
        totalItens: state.totalItens,
        totalBaixo: state.totalBaixo,
      totalPecasFisicas: state.totalPecasFisicas,
      valorTotalEstoque: state.valorTotalEstoque,
      valorTotalVenda: state.valorTotalVenda,
        categorias: state.categorias,
        catIdSelecionada: evento.catId,
        catNomeSelecionada: evento.catNome,
        subcategorias: subcategorias,
      ));
    } catch (e) {
      emit(EstoqueState(
        erro: e.toString(),
        totalItens: state.totalItens,
        totalBaixo: state.totalBaixo,
      totalPecasFisicas: state.totalPecasFisicas,
      valorTotalEstoque: state.valorTotalEstoque,
      valorTotalVenda: state.valorTotalVenda,
        categorias: state.categorias,
      ));
    }
  }

  Future<void> _onSubcategoriaSelecionada(SubcategoriaSelecionada evento, Emitter<EstoqueState> emit) async {
    emit(EstoqueState(
      carregando: true,
      totalItens: state.totalItens,
      totalBaixo: state.totalBaixo,
      totalPecasFisicas: state.totalPecasFisicas,
      valorTotalEstoque: state.valorTotalEstoque,
      valorTotalVenda: state.valorTotalVenda,
      categorias: state.categorias,
      catIdSelecionada: state.catIdSelecionada,
      catNomeSelecionada: state.catNomeSelecionada,
      subcategorias: state.subcategorias,
    ));
    try {
      final produtos = await _service.buscarProdutos(evento.subId);
      emit(EstoqueState(
        nivel: NivelEstoque.produtos,
        totalItens: state.totalItens,
        totalBaixo: state.totalBaixo,
      totalPecasFisicas: state.totalPecasFisicas,
      valorTotalEstoque: state.valorTotalEstoque,
      valorTotalVenda: state.valorTotalVenda,
        categorias: state.categorias,
        catIdSelecionada: state.catIdSelecionada,
        catNomeSelecionada: state.catNomeSelecionada,
        subcategorias: state.subcategorias,
        subIdSelecionada: evento.subId,
        subNomeSelecionada: evento.subNome,
        produtos: produtos,
      ));
    } catch (e) {
      emit(EstoqueState(
        erro: e.toString(),
        nivel: NivelEstoque.subcategorias,
        totalItens: state.totalItens,
        totalBaixo: state.totalBaixo,
      totalPecasFisicas: state.totalPecasFisicas,
      valorTotalEstoque: state.valorTotalEstoque,
      valorTotalVenda: state.valorTotalVenda,
        categorias: state.categorias,
        catIdSelecionada: state.catIdSelecionada,
        catNomeSelecionada: state.catNomeSelecionada,
        subcategorias: state.subcategorias,
      ));
    }
  }

  void _onBreadcrumbTocado(BreadcrumbTocado evento, Emitter<EstoqueState> emit) {
    switch (evento.nivel) {
      case NivelEstoque.categorias:
        emit(EstoqueState(
          nivel: NivelEstoque.categorias,
          totalItens: state.totalItens,
          totalBaixo: state.totalBaixo,
      totalPecasFisicas: state.totalPecasFisicas,
      valorTotalEstoque: state.valorTotalEstoque,
      valorTotalVenda: state.valorTotalVenda,
          categorias: state.categorias,
        ));
      case NivelEstoque.subcategorias:
        emit(EstoqueState(
          nivel: NivelEstoque.subcategorias,
          totalItens: state.totalItens,
          totalBaixo: state.totalBaixo,
      totalPecasFisicas: state.totalPecasFisicas,
      valorTotalEstoque: state.valorTotalEstoque,
      valorTotalVenda: state.valorTotalVenda,
          categorias: state.categorias,
          catIdSelecionada: state.catIdSelecionada,
          catNomeSelecionada: state.catNomeSelecionada,
          subcategorias: state.subcategorias,
        ));
      default:
        break;
    }
  }

  void _onBuscaAlterada(BuscaAlterada evento, Emitter<EstoqueState> emit) {
    emit(_preservandoComFiltros(busca: evento.query));
  }

  void _onFiltroStatusAlterado(FiltroStatusAlterado evento, Emitter<EstoqueState> emit) {
    emit(_preservandoComFiltros(filtroStatus: evento.status, limparFiltro: evento.status == null));
  }

  Future<void> _onProdutoExcluido(ProdutoExcluido evento, Emitter<EstoqueState> emit) async {
    try {
      await _service.deletarProduto(evento.id);
      final produtos = await _service.buscarProdutos(state.subIdSelecionada!);
      emit(EstoqueState(
        nivel: NivelEstoque.produtos,
        totalItens: state.totalItens,
        totalBaixo: state.totalBaixo,
      totalPecasFisicas: state.totalPecasFisicas,
      valorTotalEstoque: state.valorTotalEstoque,
      valorTotalVenda: state.valorTotalVenda,
        categorias: state.categorias,
        catIdSelecionada: state.catIdSelecionada,
        catNomeSelecionada: state.catNomeSelecionada,
        subcategorias: state.subcategorias,
        subIdSelecionada: state.subIdSelecionada,
        subNomeSelecionada: state.subNomeSelecionada,
        produtos: produtos,
        acao: AcaoEstoque.produtoDeletado,
      ));
    } catch (e) {
      emit(_preservandoComFiltros(erro: e.toString()));
    }
  }

  Future<void> _onProdutoSalvo(ProdutoSalvo evento, Emitter<EstoqueState> emit) async {
    try {
      if (evento.isEdicao) {
        await _service.atualizarProduto(evento.produto);
      } else {
        await _service.criarProduto(evento.produto, state.subIdSelecionada!);
      }
      final produtos = await _service.buscarProdutos(state.subIdSelecionada!);
      emit(EstoqueState(
        nivel: NivelEstoque.produtos,
        totalItens: state.totalItens,
        totalBaixo: state.totalBaixo,
      totalPecasFisicas: state.totalPecasFisicas,
      valorTotalEstoque: state.valorTotalEstoque,
      valorTotalVenda: state.valorTotalVenda,
        categorias: state.categorias,
        catIdSelecionada: state.catIdSelecionada,
        catNomeSelecionada: state.catNomeSelecionada,
        subcategorias: state.subcategorias,
        subIdSelecionada: state.subIdSelecionada,
        subNomeSelecionada: state.subNomeSelecionada,
        produtos: produtos,
        acao: AcaoEstoque.produtoSalvo,
      ));
    } catch (e) {
      emit(_preservandoComFiltros(erro: e.toString()));
    }
  }

  EstoqueState _preservandoComFiltros({
    String? busca,
    StatusEstoque? filtroStatus,
    bool limparFiltro = false,
    String? erro,
  }) {
    return EstoqueState(
      nivel: state.nivel,
      totalItens: state.totalItens,
      totalBaixo: state.totalBaixo,
      totalPecasFisicas: state.totalPecasFisicas,
      valorTotalEstoque: state.valorTotalEstoque,
      categorias: state.categorias,
      catIdSelecionada: state.catIdSelecionada,
      catNomeSelecionada: state.catNomeSelecionada,
      subcategorias: state.subcategorias,
      subIdSelecionada: state.subIdSelecionada,
      subNomeSelecionada: state.subNomeSelecionada,
      produtos: state.produtos,
      busca: busca ?? state.busca,
      filtroStatus: limparFiltro ? null : (filtroStatus ?? state.filtroStatus),
      erro: erro,
    );
  }
}
