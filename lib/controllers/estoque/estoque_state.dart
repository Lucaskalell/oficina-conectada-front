part of 'estoque_controller.dart';

abstract class EstoqueState extends Equatable {
  const EstoqueState();

  @override
  List<Object?> get props => [];
}

class EstoqueInitial extends EstoqueState {}

class EstoqueLoading extends EstoqueState {}

class EstoqueSucesso extends EstoqueState {
  final List<CategoriaModel> categorias;
  const EstoqueSucesso(this.categorias);

  @override
  List<Object?> get props => [categorias];
}

class EstoqueErro extends EstoqueState {
  final String mensagem;
  const EstoqueErro(this.mensagem);

  @override
  List<Object?> get props => [mensagem];
}

class ResumoLoading extends EstoqueState {}

class ResumoSucesso extends EstoqueState {
  final EstoqueResumoModel resumo;
  const ResumoSucesso(this.resumo);

  @override
  List<Object?> get props => [resumo];
}

class ResumoErro extends EstoqueState {
  final String mensagem;
  const ResumoErro(this.mensagem);

  @override
  List<Object?> get props => [mensagem];
}
