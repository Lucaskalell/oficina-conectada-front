part of 'produto_controller.dart';

abstract class ProdutoState extends Equatable {
  const ProdutoState();

  @override
  List<Object?> get props => [];
}

class ProdutoInitial extends ProdutoState {}

class ProdutoLoading extends ProdutoState {}

class ProdutoSuccess extends ProdutoState {
  final List<ProdutoModel> produtos;
  const ProdutoSuccess(this.produtos);

  @override
  List<Object?> get props => [produtos];
}

class ProdutoError extends ProdutoState {
  final String mensagem;
  const ProdutoError(this.mensagem);

  @override
  List<Object?> get props => [mensagem];
}
