import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:oficina_conectada_front/estoque/estoque_repository.dart';

import '../model/model_ordem_produto/categoria.dart';
import '../model/model_ordem_produto/estoque_resumo.dart';



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
    
    on<BuscarResumoIniciado>((event, emit)async{
      emit(ResumoLoading());
      try{
        final resumo = await estoqueRepository.getResumoEstoque();
        emit(ResumoSucesso(resumo));
      }catch (e,s){
        debugPrint('segue erro e o caminho do erro: $e\n$s');
        emit(ResumoErro(e.toString()));
      }
    });
  }
}
