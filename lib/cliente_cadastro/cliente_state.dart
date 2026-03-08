import 'package:oficina_conectada_front/model/cliente_model.dart';

abstract class ClienteState {}

class ClienteInitial extends ClienteState {}

class ClienteLoading extends ClienteState {}

class ClienteLoaded extends ClienteState {
  final List<ClienteModel> clientes;

  ClienteLoaded(this.clientes);
}

class ClienteActionSuccess extends ClienteState {
  final String mensagem;

  ClienteActionSuccess(this.mensagem);
}

class ClienteError extends ClienteState {
  final String mensagem;

  ClienteError(this.mensagem);
}
