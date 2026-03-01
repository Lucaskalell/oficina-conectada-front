
import '../../model/add_ordem_de_servico/ordem_de_servico_model.dart';

abstract class AdicionarOrdemEvent {}

class CarregarClientesEvent extends AdicionarOrdemEvent {}

class CarregarDadosClienteCompletoEvent extends AdicionarOrdemEvent {
  final int clienteId;
  CarregarDadosClienteCompletoEvent(this.clienteId);
}

class CriarOrdemDeServicoEvent extends AdicionarOrdemEvent {
  final OrdemDeServicoModel ordemDeServico;
  CriarOrdemDeServicoEvent(this.ordemDeServico);
}


class CriarOSComNovoClienteEvent extends AdicionarOrdemEvent{
  final Map<String, dynamic> clienteCarroData;
  final OrdemDeServicoModel ordemDeServico;
  CriarOSComNovoClienteEvent(this.clienteCarroData, this.ordemDeServico);
}