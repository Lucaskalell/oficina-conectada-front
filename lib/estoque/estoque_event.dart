

part of'estoque_bloc.dart';


@immutable
abstract class EstoqueEvent extends Equatable{
  const EstoqueEvent();

  @override
  List<Object> get props => [];
}

class BuscarCategoriasIniciado extends EstoqueEvent{}

class BuscarCategoriasSucesso extends EstoqueEvent{}

class BuscarCategoriasFalhou extends EstoqueEvent{}

class BuscarProdutosIniciado extends EstoqueEvent{}

class BuscarProdutosSucesso extends EstoqueEvent{}

class BuscarProdutosFalhou extends EstoqueEvent{}
