import 'package:oficina_conectada_front/model/add_ordem_de_servico/ordem_de_servico_model.dart';

abstract class OrdemDeServicoEvent {}

class CarregarOrdemDeServicoById extends OrdemDeServicoEvent {
  final int id;
  CarregarOrdemDeServicoById(this.id);
}

class CarregarListaDeOrdemDeServico extends OrdemDeServicoEvent {}

class EditarOrdemById extends OrdemDeServicoEvent {
  final OrdemDeServicoModel ordemDeServico;
  EditarOrdemById(this.ordemDeServico);
}

class DeletarOrdemDeServico extends OrdemDeServicoEvent {
  final int id;
  DeletarOrdemDeServico(this.id);
}


