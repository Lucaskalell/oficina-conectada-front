part of 'sub_categoria_bloc.dart';

abstract class SubCategoriaEvent extends Equatable {
  const SubCategoriaEvent();
  @override
  List<Object> get props => [];
}

class BuscarSubCategoriasIniciado extends SubCategoriaEvent {
  final int categoriaId;
  const BuscarSubCategoriasIniciado(this.categoriaId);
  @override
  List<Object> get props => [categoriaId];
}
