import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:oficina_conectada_front/services/estoque_service.dart';
import 'package:oficina_conectada_front/models/categoria_model.dart';
import 'package:oficina_conectada_front/models/estoque_resumo_model.dart';

part 'estoque_event.dart';
part 'estoque_state.dart';

class EstoqueController extends Bloc<EstoqueEvent, EstoqueState> {
  final EstoqueService _service;

  EstoqueController(this._service) : super(EstoqueInitial()) {
    on<BuscarCategoriasIniciado>((event, emit) async {
      emit(EstoqueLoading());
      try {
        final categorias = await _service.buscarCategorias();
        emit(EstoqueSucesso(categorias));
      } catch (e) {
        emit(EstoqueErro(e.toString()));
      }
    });

    on<BuscarResumoIniciado>((event, emit) async {
      emit(ResumoLoading());
      try {
        final resumo = await _service.getResumoEstoque();
        emit(ResumoSucesso(resumo));
      } catch (e, s) {
        debugPrint('Erro ao buscar resumo do estoque: $e\n$s');
        emit(ResumoErro(e.toString()));
      }
    });
  }
}
