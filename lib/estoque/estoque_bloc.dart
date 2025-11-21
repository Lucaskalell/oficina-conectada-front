import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:oficina_conectada_front/estoque/estoque_repository.dart';

import 'model/categoria.dart';

part 'estoque_event.dart';
part 'estoque_state.dart';

class EstoqueBloc extends Bloc<EstoqueEvent, EstoqueState> {
  final EstoqueRepository _estoqueRepository;

  EstoqueBloc(this._estoqueRepository) : super(EstoqueInitial()) {
    on<BuscarCategoriasIniciado>(_onBuscarCategoriasIniciado);
  }
  Future<void> _onBuscarCategoriasIniciado(BuscarCategoriasIniciado event, Emitter<EstoqueState> emit) async {
    emit(EstoqueLoading());
    try {
      final categorias = await _estoqueRepository.buscarCategorias();

      emit(EstoqueSucesso(categorias));
    } catch (e) {
      emit(EstoqueErro(e.toString()));
    }
  }

}
