
part of 'estoque_bloc.dart';


@immutable
abstract class EstoqueState extends Equatable {
  const EstoqueState();

  @override
  List<Object> get props => [];
}

class EstoqueInitial extends EstoqueState {}

class EstoqueLoading extends EstoqueState {}

class EstoqueSucesso extends EstoqueState {
  final List<Categoria> categorias;
  const EstoqueSucesso(this.categorias);

  @override
  List<Object> get props => [categorias];
}



class EstoqueErro extends EstoqueState{
  final String mensagem;
  const EstoqueErro(this.mensagem);

  @override
  List<Object> get props => [mensagem];
}
