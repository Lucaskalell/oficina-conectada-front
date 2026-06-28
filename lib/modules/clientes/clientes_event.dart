import 'package:equatable/equatable.dart';
import 'package:oficina_conectada_front/models/cliente_carro_request_model.dart';
import 'package:oficina_conectada_front/models/cliente_model.dart';

abstract class ClientesEvent extends Equatable {
  const ClientesEvent();

  @override
  List<Object?> get props => [];
}

class CarregarClientes extends ClientesEvent {}

class CriarClienteSimples extends ClientesEvent {
  final ClienteModel cliente;
  const CriarClienteSimples(this.cliente);

  @override
  List<Object?> get props => [cliente];
}

class CriarClienteComCarro extends ClientesEvent {
  final ClienteCarroRequestModel dto;
  const CriarClienteComCarro(this.dto);

  @override
  List<Object?> get props => [dto];
}

class DeletarCliente extends ClientesEvent {
  final int id;
  const DeletarCliente(this.id);

  @override
  List<Object?> get props => [id];
}
