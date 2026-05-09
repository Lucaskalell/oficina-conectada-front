part of 'cliente_controller.dart';

abstract class ClienteState extends Equatable {
  const ClienteState();

  @override
  List<Object?> get props => [];
}

class ClienteInitial extends ClienteState {}

class ClienteLoading extends ClienteState {}

class ClienteLoaded extends ClienteState {
  final List<ClienteModel> clientes;
  const ClienteLoaded(this.clientes);

  @override
  List<Object?> get props => [clientes];
}

class ClienteError extends ClienteState {
  final String message;
  const ClienteError(this.message);

  @override
  List<Object?> get props => [message];
}
