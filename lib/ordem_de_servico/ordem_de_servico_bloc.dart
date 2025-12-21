import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'ordem_de_servico_event.dart';
import 'ordem_de_servico_repository.dart';
import 'ordem_de_servico_state.dart';

class OrdemDeServicoBloc extends Bloc<OrdemDeServicoEvent, OrdemDeServicoState> {
  final OrdemDeServicoRepository repository;

  OrdemDeServicoBloc(this.repository) : super(OrdemDeServicoInitialState()) {
    on<CarregarListaDeOrdemDeServico>((event, emit) async {
      emit(OrdemDeServicoLoadingState());
      try {
        final ordensDeServicos = await repository.getOrdensDeServico();
        emit(OrdemDeServicoListSuccessState(ordensDeServicos));
      } catch (e, stackTrace) {
        debugPrint('Deu erro e segue caminho do erro :$e,$stackTrace');
        emit(OrdemDeServicoErrorState(e.toString()));
      }
    });

    on<CarregarOrdemDeServicoById>((event, emit) async {
      emit(OrdemDeServicoLoadingState());
      try {
        final ordemDeServico = await repository.getOrdenDeServicoById(event.id);
        emit(OrdemDeServicoSuccessState(ordemDeServico));
      } catch (e, stackTrace) {
        debugPrint('Deu erro e segue caminho do erro :$e,$stackTrace');
        emit(OrdemDeServicoErrorState(e.toString()));
      }
    });

    on<DeletarOrdemDeServico>((event, emit) async {
      emit(OrdemDeServicoLoadingDeleteState());
      try {
        await repository.deletarOrdenDeServico(event.id);
        emit(OrdemDeServicoDelatadaComSucesso('Ordem de serviço deletada com sucesso'));
        final ordensDeServicos = await repository.getOrdensDeServico();
        emit(OrdemDeServicoListSuccessState(ordensDeServicos));
      } catch (e, s) {
        debugPrint('Deu erro e segue caminho do erro :$e,$s');
        emit(OrdemDeServicoErrorState(e.toString()));
      }
    });


    on<EditarOrdemById>((event, emit) async {
      try {
        emit(OrdemDeServicoLoadingState());
        final ordemDeServico = await repository.putOrdenDeServico(event.ordemDeServico);
        emit(OrdemDeServicoSuccessState(ordemDeServico));
      } catch (e, s) {
        debugPrint('Deu erro e segue caminho do erro :$e,$s');
        emit(OrdemDeServicoErrorState(e.toString()));
      }
    });
  }
}
