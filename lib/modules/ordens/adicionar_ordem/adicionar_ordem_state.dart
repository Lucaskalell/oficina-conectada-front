import 'package:equatable/equatable.dart';
import 'package:oficina_conectada_front/models/carro_model.dart';
import 'package:oficina_conectada_front/models/cliente_model.dart';

abstract class AdicionarOrdemState extends Equatable {
  const AdicionarOrdemState();

  @override
  List<Object?> get props => [];
}

class AdicionarOrdemInicial extends AdicionarOrdemState {}

class AdicionarOrdemCarregando extends AdicionarOrdemState {}

class AdicionarOrdemSucesso extends AdicionarOrdemState {}

class AdicionarOrdemErro extends AdicionarOrdemState {
  final String mensagem;

  const AdicionarOrdemErro(this.mensagem);

  @override
  List<Object?> get props => [mensagem];
}

class ClientesCarregados extends AdicionarOrdemState {
  final List<ClienteModel> clientes;

  const ClientesCarregados(this.clientes);

  @override
  List<Object?> get props => [clientes];
}

class CarrosClienteCarregados extends AdicionarOrdemState {
  final List<CarroModel> carros;

  const CarrosClienteCarregados(this.carros);

  @override
  List<Object?> get props => [carros];
}

class CadastrarClienteCarregando extends AdicionarOrdemState {}

class CadastrarClienteSucesso extends AdicionarOrdemState {
  final ClienteModel cliente;

  const CadastrarClienteSucesso(this.cliente);

  @override
  List<Object?> get props => [cliente];
}

class CadastrarClienteErro extends AdicionarOrdemState {
  final String mensagem;

  const CadastrarClienteErro(this.mensagem);

  @override
  List<Object?> get props => [mensagem];
}
