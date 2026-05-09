import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oficina_conectada_front/services/ordem_de_servico_service.dart';
import 'adicionar_ordem_event.dart';
import 'adicionar_ordem_state.dart';

class AdicionarOrdemController
    extends Bloc<AdicionarOrdemEvent, AdicionarOrdemState> {
  final OrdemDeServicoService service;

  AdicionarOrdemController(this.service) : super(AdicionarOrdemInitialState()) {
    // Carregar lista de clientes para o dropdown
    on<CarregarClientesEvent>((event, emit) async {
      emit(AdicionarOrdemLoadingState());
      try {
        final clientes = await service.getClientes();
        emit(ClientesCarregadosState(clientes));
      } catch (e) {
        emit(AdicionarOrdemErrorState(e.toString()));
      }
    });

    // Carregar carros do cliente selecionado
    on<CarregarDadosClienteCompletoEvent>((event, emit) async {
      try {
        final clienteCompleto = await service.getClienteCompleto(event.clienteId);
        emit(DadosClienteCompletoCarregadosState(clienteCompleto.carros ?? []));
      } catch (e) {
        emit(AdicionarOrdemErrorState(e.toString()));
      }
    });

    // Criar a OS
    on<CriarOrdemDeServicoEvent>((event, emit) async {
      emit(AdicionarOrdemLoadingState());
      try {
        await service.postOrdemDeServico(event.ordemDeServico);
        emit(AdicionarOrdemSuccessState());
      } catch (e) {
        emit(AdicionarOrdemErrorState(e.toString()));
      }
    });

    on<CadastrarNovoClienteECarroEvent>((event, emit) async {
      emit(CadastrarClienteLoadingState());
      try {
        final clienteNovo = await service.postClienteComCarroNovo(event.dadosCadastro);
        emit(CadastrarClienteSuccessState(clienteNovo));
      } catch (e) {
        emit(CadastrarClienteErrorState('Erro ao cadastrar cliente e veículo: $e'));
      }
    });
  }
}
