import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oficina_conectada_front/modules/clientes/clientes_event.dart';
import 'package:oficina_conectada_front/modules/clientes/clientes_service.dart';
import 'package:oficina_conectada_front/modules/clientes/clientes_state.dart';

class ClientesBloc extends Bloc<ClientesEvent, ClientesState> {
  final ClientesService _clientesService;

  ClientesBloc(this._clientesService) : super(ClientesInicial()) {
    on<CarregarClientes>(_onCarregarClientes);
    on<CriarClienteSimples>(_onCriarClienteSimples);
    on<CriarClienteComCarro>(_onCriarClienteComCarro);
    on<DeletarCliente>(_onDeletarCliente);
  }

  Future<void> _onCarregarClientes(
    CarregarClientes evento,
    Emitter<ClientesState> emit,
  ) async {
    emit(ClientesCarregando());
    try {
      final clientes = await _clientesService.buscarClientes();
      emit(ClientesCarregados(clientes));
    } catch (e) {
      emit(ClientesErro(e.toString()));
    }
  }

  Future<void> _onCriarClienteSimples(
    CriarClienteSimples evento,
    Emitter<ClientesState> emit,
  ) async {
    emit(ClientesCarregando());
    try {
      await _clientesService.criarClienteSimples(evento.cliente);
      add(CarregarClientes());
    } catch (e) {
      emit(ClientesErro(e.toString()));
    }
  }

  Future<void> _onCriarClienteComCarro(
    CriarClienteComCarro evento,
    Emitter<ClientesState> emit,
  ) async {
    emit(ClientesCarregando());
    try {
      await _clientesService.criarClienteComCarro(evento.dto);
      add(CarregarClientes());
    } catch (e) {
      emit(ClientesErro(e.toString()));
    }
  }

  Future<void> _onDeletarCliente(
    DeletarCliente evento,
    Emitter<ClientesState> emit,
  ) async {
    try {
      await _clientesService.deletarCliente(evento.id);
      emit(ClienteDeletado());
      add(CarregarClientes());
    } catch (e) {
      emit(ClientesErro(e.toString()));
    }
  }
}
