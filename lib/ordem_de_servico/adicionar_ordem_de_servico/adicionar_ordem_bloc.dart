
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oficina_conectada_front/ordem_de_servico/ordem_de_servico_repository.dart';
import 'adicionar_ordem_event.dart';
import 'adicionar_ordem_state.dart';

class AdicionarOrdemDeServicoBloc extends Bloc<AdicionarOrdemEvent, AdicionarOrdemState> {
  final OrdemDeServicoRepository repository;

  AdicionarOrdemDeServicoBloc(this.repository) : super(AdicionarOrdemInitialState()) {
    
    // Carregar lista de clientes para o dropdown
    on<CarregarClientesEvent>((event, emit) async {
      emit(AdicionarOrdemLoadingState());
      try {
        final clientes = await repository.getClientes();
        emit(ClientesCarregadosState(clientes));
      } catch (e) {
        emit(AdicionarOrdemErrorState(e.toString()));
      }
    });

    // Carregar carros do cliente selecionado
    on<CarregarDadosClienteCompletoEvent>((event, emit) async {
      try {
        final clienteCompleto = await repository.getClienteCompleto(event.clienteId);
        emit(DadosClienteCompletoCarregadosState(clienteCompleto.carros ?? []));
      } catch (e) {
        emit(AdicionarOrdemErrorState(e.toString()));
      }
    });

    // Criar a OS
    on<CriarOrdemDeServicoEvent>((event, emit) async {
      emit(AdicionarOrdemLoadingState());
      try {
        await repository.postOrdenDeServico(event.ordemDeServico);
        emit(AdicionarOrdemSuccessState());
      } catch (e) {
        emit(AdicionarOrdemErrorState(e.toString()));
      }
    });
    
  }
}
