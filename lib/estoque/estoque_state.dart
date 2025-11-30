
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

//////todo resumos
class ResumoLoading extends EstoqueState {}

class ResumoSucesso extends EstoqueState{
  final EstoqueResumo resumo;
  const ResumoSucesso(this.resumo);

  @override
  List<Object> get props => [resumo];
}

class ResumoErro extends EstoqueState {
  final String mensagem;
  const ResumoErro(this.mensagem);
  @override
  List<Object> get props => [mensagem];
}

