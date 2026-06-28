import 'package:equatable/equatable.dart';
import 'package:oficina_conectada_front/models/cliente_model.dart';

abstract class ClientesState extends Equatable {
  const ClientesState();

  @override
  List<Object?> get props => [];
}

class ClientesInicial extends ClientesState {}

class ClientesCarregando extends ClientesState {}

class ClientesCarregados extends ClientesState {
  final List<ClienteModel> clientes;
  const ClientesCarregados(this.clientes);

  @override
  List<Object?> get props => [clientes];
}

class ClienteDeletado extends ClientesState {}

class ClientesErro extends ClientesState {
  final String mensagem;
  const ClientesErro(this.mensagem);

  @override
  List<Object?> get props => [mensagem];
}
