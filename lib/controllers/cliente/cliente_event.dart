part of 'cliente_controller.dart';

abstract class ClienteEvent extends Equatable {
  const ClienteEvent();

  @override
  List<Object?> get props => [];
}

class CarregarClientes extends ClienteEvent {}

class AdicionarClienteSimples extends ClienteEvent {
  final ClienteModel cliente;
  const AdicionarClienteSimples(this.cliente);

  @override
  List<Object?> get props => [cliente];
}

class AdicionarClienteComCarro extends ClienteEvent {
  final ClienteCarroRequestModel request;
  const AdicionarClienteComCarro(this.request);

  @override
  List<Object?> get props => [request];
}

class DeletarCliente extends ClienteEvent {
  final int id;
  const DeletarCliente(this.id);

  @override
  List<Object?> get props => [id];
}
