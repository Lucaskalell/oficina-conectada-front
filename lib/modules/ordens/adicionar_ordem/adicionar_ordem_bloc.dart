import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oficina_conectada_front/modules/ordens/adicionar_ordem/adicionar_ordem_event.dart';
import 'package:oficina_conectada_front/modules/ordens/adicionar_ordem/adicionar_ordem_state.dart';
import 'package:oficina_conectada_front/modules/ordens/ordens_service.dart';

class AdicionarOrdemBloc extends Bloc<AdicionarOrdemEvent, AdicionarOrdemState> {
  final OrdensService _ordensService;

  AdicionarOrdemBloc(this._ordensService) : super(AdicionarOrdemInicial()) {
    on<CarregarClientes>(_onCarregarClientes);
    on<CarregarCarrosCliente>(_onCarregarCarrosCliente);
    on<CriarOrdem>(_onCriarOrdem);
    on<CadastrarClienteECarro>(_onCadastrarClienteECarro);
  }

  Future<void> _onCarregarClientes(
    CarregarClientes evento,
    Emitter<AdicionarOrdemState> emit,
  ) async {
    emit(AdicionarOrdemCarregando());
    try {
      final clientes = await _ordensService.buscarClientes();
      emit(ClientesCarregados(clientes));
    } catch (e) {
      emit(AdicionarOrdemErro(e.toString()));
    }
  }

  Future<void> _onCarregarCarrosCliente(
    CarregarCarrosCliente evento,
    Emitter<AdicionarOrdemState> emit,
  ) async {
    try {
      final clienteCompleto = await _ordensService.buscarClienteCompleto(evento.clienteId);
      emit(CarrosClienteCarregados(clienteCompleto.carros ?? []));
    } catch (e) {
      emit(AdicionarOrdemErro(e.toString()));
    }
  }

  Future<void> _onCriarOrdem(
    CriarOrdem evento,
    Emitter<AdicionarOrdemState> emit,
  ) async {
    emit(AdicionarOrdemCarregando());
    try {
      await _ordensService.criarOrdem(evento.ordem);
      emit(AdicionarOrdemSucesso());
    } catch (e) {
      emit(AdicionarOrdemErro(e.toString()));
    }
  }

  Future<void> _onCadastrarClienteECarro(
    CadastrarClienteECarro evento,
    Emitter<AdicionarOrdemState> emit,
  ) async {
    emit(CadastrarClienteCarregando());
    try {
      final clienteNovo = await _ordensService.criarClienteComCarro(evento.dados);
      emit(CadastrarClienteSucesso(clienteNovo));
    } catch (e) {
      emit(CadastrarClienteErro('Erro ao cadastrar cliente e veículo: $e'));
    }
  }
}
