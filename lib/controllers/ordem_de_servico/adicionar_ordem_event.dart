import 'package:equatable/equatable.dart';
import 'package:oficina_conectada_front/models/ordem_de_servico_model.dart';
import 'package:oficina_conectada_front/models/cliente_model.dart';
import 'package:oficina_conectada_front/models/carro_model.dart';

abstract class AdicionarOrdemEvent extends Equatable {
  const AdicionarOrdemEvent();

  @override
  List<Object?> get props => [];
}

class CarregarClientesEvent extends AdicionarOrdemEvent {}

class CarregarDadosClienteCompletoEvent extends AdicionarOrdemEvent {
  final int clienteId;
  const CarregarDadosClienteCompletoEvent(this.clienteId);

  @override
  List<Object?> get props => [clienteId];
}

class CriarOrdemDeServicoEvent extends AdicionarOrdemEvent {
  final OrdemDeServicoModel ordemDeServico;
  const CriarOrdemDeServicoEvent(this.ordemDeServico);

  @override
  List<Object?> get props => [ordemDeServico];
}

class CadastrarNovoClienteECarroEvent extends AdicionarOrdemEvent {
  final Map<String, dynamic> dadosCadastro;
  const CadastrarNovoClienteECarroEvent(this.dadosCadastro);

  @override
  List<Object?> get props => [dadosCadastro];
}
