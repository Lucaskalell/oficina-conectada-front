part of 'sub_categoria_bloc.dart';

abstract class SubCategoriaState extends Equatable {
  const SubCategoriaState();
  @override
  List<Object> get props => [];
}

class SubCategoriaInitial extends SubCategoriaState {}

class SubCategoriaLoading extends SubCategoriaState {}

class SubCategoriaSucesso extends SubCategoriaState {
  final List<SubCategoria> subCategorias;

  const SubCategoriaSucesso(this.subCategorias);

  @override
  List<Object> get props => [subCategorias];
}

class SubCategoriaErro extends SubCategoriaState {
  final String mensagem;

  const SubCategoriaErro(this.mensagem);

  @override
  List<Object> get props => [mensagem];
}