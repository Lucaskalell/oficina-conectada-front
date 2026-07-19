import 'package:equatable/equatable.dart';
import 'package:oficina_conectada_front/models/produto_model.dart';
import 'package:oficina_conectada_front/modules/estoque/estoque_state.dart';

abstract class EstoqueEvent extends Equatable {
  const EstoqueEvent();
  @override
  List<Object?> get props => [];
}

class EstoqueCarregado extends EstoqueEvent {}

class CategoriaSelecionada extends EstoqueEvent {
  final int catId;
  final String catNome;
  const CategoriaSelecionada(this.catId, this.catNome);
  @override
  List<Object?> get props => [catId];
}

class SubcategoriaSelecionada extends EstoqueEvent {
  final int subId;
  final String subNome;
  const SubcategoriaSelecionada(this.subId, this.subNome);
  @override
  List<Object?> get props => [subId];
}

class BreadcrumbTocado extends EstoqueEvent {
  final NivelEstoque nivel;
  const BreadcrumbTocado(this.nivel);
  @override
  List<Object?> get props => [nivel];
}

class BuscaAlterada extends EstoqueEvent {
  final String query;
  const BuscaAlterada(this.query);
  @override
  List<Object?> get props => [query];
}

class FiltroStatusAlterado extends EstoqueEvent {
  final StatusEstoque? status;
  const FiltroStatusAlterado(this.status);
  @override
  List<Object?> get props => [status];
}

class ProdutoExcluido extends EstoqueEvent {
  final int id;
  const ProdutoExcluido(this.id);
  @override
  List<Object?> get props => [id];
}

class ProdutoSalvo extends EstoqueEvent {
  final ProdutoModel produto;
  final bool isEdicao;
  const ProdutoSalvo(this.produto, {required this.isEdicao});
  @override
  List<Object?> get props => [produto, isEdicao];
}
