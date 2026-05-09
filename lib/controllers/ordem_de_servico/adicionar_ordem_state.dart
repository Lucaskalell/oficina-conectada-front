import 'package:equatable/equatable.dart';
import 'package:oficina_conectada_front/models/cliente_model.dart';
import 'package:oficina_conectada_front/models/carro_model.dart';

abstract class AdicionarOrdemState extends Equatable {
  const AdicionarOrdemState();

  @override
  List<Object?> get props => [];
}

class AdicionarOrdemInitialState extends AdicionarOrdemState {}

class AdicionarOrdemLoadingState extends AdicionarOrdemState {}

class AdicionarOrdemSuccessState extends AdicionarOrdemState {}

class AdicionarOrdemErrorState extends AdicionarOrdemState {
  final String message;
  const AdicionarOrdemErrorState(this.message);

  @override
  List<Object?> get props => [message];
}

class ClientesCarregadosState extends AdicionarOrdemState {
  final List<ClienteModel> clientes;
  const ClientesCarregadosState(this.clientes);

  @override
  List<Object?> get props => [clientes];
}

class DadosClienteCompletoCarregadosState extends AdicionarOrdemState {
  final List<CarroModel> carros;
  const DadosClienteCompletoCarregadosState(this.carros);

  @override
  List<Object?> get props => [carros];
}

class CadastrarClienteLoadingState extends AdicionarOrdemState {}

class CadastrarClienteSuccessState extends AdicionarOrdemState {
  final ClienteModel cliente;
  const CadastrarClienteSuccessState(this.cliente);

  @override
  List<Object?> get props => [cliente];
}

class CadastrarClienteErrorState extends AdicionarOrdemState {
  final String message;
  const CadastrarClienteErrorState(this.message);

  @override
  List<Object?> get props => [message];
}
