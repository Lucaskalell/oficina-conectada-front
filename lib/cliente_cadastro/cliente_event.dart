import 'package:oficina_conectada_front/model/cliente_carro_request_model.dart';
import 'package:oficina_conectada_front/model/cliente_model.dart';

abstract class ClienteEvent {}

class CarregarClientes extends ClienteEvent {}

class CriarClienteSimples extends ClienteEvent {
  final ClienteModel cliente;

  CriarClienteSimples(this.cliente);
}

class CriarClienteComCarro extends ClienteEvent {
  final ClienteCarroRequestModel dto;

  CriarClienteComCarro(this.dto);
}

class DeletarCliente extends ClienteEvent {
  final int clienteId;

  DeletarCliente(this.clienteId);
}
