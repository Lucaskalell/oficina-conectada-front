

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:oficina_conectada_front/estoque/sub_categoria/sub_categoria_repository.dart';

import '../../model/model_ordem_produto/sub_categoria.dart';



part 'sub_categoria_event.dart';
part 'sub_categoria_state.dart';

class SubCategoriaBloc extends Bloc<SubCategoriaEvent, SubCategoriaState> {
  final SubCategoriaRepository repository;
  SubCategoriaBloc(this.repository) : super(SubCategoriaInitial()) {
    on<BuscarSubCategoriasIniciado>((event,emit,) async {
      emit(SubCategoriaLoading());
      try {
        final subCategorias = await repository.buscarSubCategorias(event.categoriaId);
        emit(SubCategoriaSucesso(subCategorias));
      } catch (e) {
        emit(SubCategoriaErro(e.toString()));
      }
    });
  }
}
