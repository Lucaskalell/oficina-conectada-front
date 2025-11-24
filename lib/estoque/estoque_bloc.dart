import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:oficina_conectada_front/estoque/estoque_repository.dart';

import 'model/categoria.dart';

part 'estoque_event.dart';
part 'estoque_state.dart';

class EstoqueBloc extends Bloc<EstoqueEvent, EstoqueState> {
  final EstoqueRepository estoqueRepository;

  EstoqueBloc(this.estoqueRepository) : super(EstoqueInitial()) {


    on<BuscarCategoriasIniciado>((event, emit) async {
      emit(EstoqueLoading());
      try {
        final categorias = await estoqueRepository.buscarCategorias();

        emit(EstoqueSucesso(categorias));
      } catch (e) {
        emit(EstoqueErro(e.toString()));
      }
    });
  }
}
