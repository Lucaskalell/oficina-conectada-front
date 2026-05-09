import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:oficina_conectada_front/services/sub_categoria_service.dart';
import 'package:oficina_conectada_front/models/sub_categoria_model.dart';

part 'sub_categoria_event.dart';
part 'sub_categoria_state.dart';

class SubCategoriaController
    extends Bloc<SubCategoriaEvent, SubCategoriaState> {
  final SubCategoriaService _service;

  SubCategoriaController(this._service) : super(SubCategoriaInitial()) {
    on<BuscarSubCategoriasIniciado>((event, emit) async {
      emit(SubCategoriaLoading());
      try {
        final subCategorias = await _service.buscarSubCategorias(event.categoriaId);
        emit(SubCategoriaSucesso(subCategorias));
      } catch (e) {
        emit(SubCategoriaErro(e.toString()));
      }
    });
  }
}
