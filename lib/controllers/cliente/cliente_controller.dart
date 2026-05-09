import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:oficina_conectada_front/models/cliente_model.dart';
import 'package:oficina_conectada_front/services/cliente_service.dart';
import 'package:oficina_conectada_front/models/cliente_carro_request_model.dart';

part 'cliente_event.dart';
part 'cliente_state.dart';

class ClienteController extends Bloc<ClienteEvent, ClienteState> {
  final ClienteService _clienteService;

  ClienteController(this._clienteService) : super(ClienteInitial()) {
    on<CarregarClientes>(_onCarregarClientes);
    on<AdicionarClienteSimples>(_onAdicionarClienteSimples);
    on<AdicionarClienteComCarro>(_onAdicionarClienteComCarro);
    on<DeletarCliente>(_onDeletarCliente);
  }

  Future<void> _onCarregarClientes(
    CarregarClientes event,
    Emitter<ClienteState> emit,
  ) async {
    emit(ClienteLoading());
    try {
      final clientes = await _clienteService.getClientes();
      emit(ClienteLoaded(clientes));
    } catch (e) {
      emit(ClienteError(e.toString()));
    }
  }

  Future<void> _onAdicionarClienteSimples(
    AdicionarClienteSimples event,
    Emitter<ClienteState> emit,
  ) async {
    emit(ClienteLoading());
    try {
      await _clienteService.criarClienteSimples(event.cliente);
      add(CarregarClientes());
    } catch (e) {
      emit(ClienteError(e.toString()));
    }
  }

  Future<void> _onAdicionarClienteComCarro(
    AdicionarClienteComCarro event,
    Emitter<ClienteState> emit,
  ) async {
    emit(ClienteLoading());
    try {
      await _clienteService.criarClienteComCarro(event.request);
      add(CarregarClientes());
    } catch (e) {
      emit(ClienteError(e.toString()));
    }
  }

  Future<void> _onDeletarCliente(
    DeletarCliente event,
    Emitter<ClienteState> emit,
  ) async {
    try {
      await _clienteService.deletarCliente(event.id);
      add(CarregarClientes());
    } catch (e) {
      emit(ClienteError(e.toString()));
    }
  }
}
