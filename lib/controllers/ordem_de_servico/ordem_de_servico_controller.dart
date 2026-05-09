import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oficina_conectada_front/services/ordem_de_servico_service.dart';
import 'package:oficina_conectada_front/controllers/ordem_de_servico/ordem_de_servico_event.dart';
import 'package:oficina_conectada_front/controllers/ordem_de_servico/ordem_de_servico_state.dart';

export 'package:oficina_conectada_front/controllers/ordem_de_servico/ordem_de_servico_event.dart';
export 'package:oficina_conectada_front/controllers/ordem_de_servico/ordem_de_servico_state.dart';

class OrdemDeServicoController
    extends Bloc<OrdemDeServicoEvent, OrdemDeServicoState> {
  final OrdemDeServicoService service;

  OrdemDeServicoController(this.service) : super(OrdemDeServicoInitialState()) {
    on<CarregarListaDeOrdemDeServico>((event, emit) async {
      emit(OrdemDeServicoLoadingState());
      try {
        final ordensDeServicos = await service.getOrdensDeServico();
        emit(OrdemDeServicoListSuccessState(ordensDeServicos));
      } catch (e, stackTrace) {
        debugPrint('Erro ao carregar lista de OS: $e, $stackTrace');
        emit(OrdemDeServicoErrorState(e.toString()));
      }
    });

    on<CarregarOrdemDeServicoById>((event, emit) async {
      emit(OrdemDeServicoLoadingState());
      try {
        final ordemDeServico = await service.getOrdemDeServicoById(event.id);
        emit(OrdemDeServicoSuccessState(ordemDeServico));
      } catch (e, stackTrace) {
        debugPrint('Erro ao carregar OS por ID: $e, $stackTrace');
        emit(OrdemDeServicoErrorState(e.toString()));
      }
    });

    on<DeletarOrdemDeServico>((event, emit) async {
      emit(OrdemDeServicoLoadingDeleteState());
      try {
        await service.deletarOrdemDeServico(event.id);
        emit(
          OrdemDeServicoDeletadaComSucesso('Ordem de serviço deletada com sucesso'),
        );
        final ordensDeServicos = await service.getOrdensDeServico();
        emit(OrdemDeServicoListSuccessState(ordensDeServicos));
      } catch (e, s) {
        debugPrint('Erro ao deletar OS: $e, $s');
        emit(OrdemDeServicoErrorState(e.toString()));
      }
    });

    on<EditarOrdemById>((event, emit) async {
      try {
        emit(OrdemDeServicoLoadingState());
        final ordemDeServico = await service.putOrdemDeServico(event.ordemDeServico);
        emit(OrdemDeServicoSuccessState(ordemDeServico));
      } catch (e, s) {
        debugPrint('Erro ao editar OS: $e, $s');
        emit(OrdemDeServicoErrorState(e.toString()));
      }
    });
  }
}
