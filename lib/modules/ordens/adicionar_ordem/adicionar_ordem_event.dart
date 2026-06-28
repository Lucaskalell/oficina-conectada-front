import 'package:equatable/equatable.dart';
import 'package:oficina_conectada_front/modules/ordens/ordens_model.dart';

abstract class AdicionarOrdemEvent extends Equatable {
  const AdicionarOrdemEvent();

  @override
  List<Object?> get props => [];
}

class CarregarClientes extends AdicionarOrdemEvent {}

class CarregarCarrosCliente extends AdicionarOrdemEvent {
  final int clienteId;

  const CarregarCarrosCliente(this.clienteId);

  @override
  List<Object?> get props => [clienteId];
}

class CriarOrdem extends AdicionarOrdemEvent {
  final OrdemDeServicoModel ordem;

  const CriarOrdem(this.ordem);

  @override
  List<Object?> get props => [ordem];
}

class CadastrarClienteECarro extends AdicionarOrdemEvent {
  final Map<String, dynamic> dados;

  const CadastrarClienteECarro(this.dados);

  @override
  List<Object?> get props => [dados];
}
