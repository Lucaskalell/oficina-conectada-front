import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oficina_conectada_front/cliente_cadastro/cliente_event.dart';
import 'package:oficina_conectada_front/cliente_cadastro/cliente_repository.dart';
import 'package:oficina_conectada_front/cliente_cadastro/cliente_state.dart';

class ClienteBloc extends Bloc<ClienteEvent, ClienteState> {
  final ClienteRepository _repository;

  ClienteBloc(this._repository) : super(ClienteInitial()) {

    on<CarregarClientes>((event, emit) async {
      emit(ClienteLoading());
      try {
        final clientes = await _repository.getClientes();
        emit(ClienteLoaded(clientes));
      } catch (e) {
        emit(ClienteError('Erro ao buscar clientes: $e'));
      }
    });
    on<CriarClienteSimples>((event, emit) async {
      emit(ClienteLoading());
      try {
        await _repository.criarClienteSimples(event.cliente);
        emit(ClienteActionSuccess('Cliente cadastrado com sucesso!'));
        add(CarregarClientes());
      } catch (e) {
        emit(ClienteError('Erro ao cadastrar cliente: $e'));
        add(CarregarClientes());
      }
    });

    on<CriarClienteComCarro>((event, emit) async {
      emit(ClienteLoading());
      try {
        await _repository.criarClienteComCarro(event.dto);
        emit(ClienteActionSuccess('Cliente e veículo cadastrados com sucesso!'));
        add(CarregarClientes());
      } catch (e) {
        emit(ClienteError('Erro ao cadastrar cliente com veículo: $e'));
        add(CarregarClientes());
      }
    });

    on<DeletarCliente>((event, emit) async {
      emit(ClienteLoading());
      try {
        await _repository.deletarCliente(event.clienteId);
        emit(ClienteActionSuccess('Cliente excluído com sucesso!'));
        add(CarregarClientes());
      } catch (e) {
        emit(ClienteError('Erro ao excluir cliente: $e'));
        add(CarregarClientes());
      }
    });

  }
}