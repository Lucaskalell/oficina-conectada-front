import 'package:oficina_conectada_front/ordem_de_servico/model/ordem_de_servico_model.dart';

abstract class AdicionarOrdemEvent{}

class CriarOrdemDeServico extends AdicionarOrdemEvent {
  final OrdemDeServicoModel criarOrdemDeServico;
  CriarOrdemDeServico(this.criarOrdemDeServico);
}
class CarregarOrdemDeServico extends AdicionarOrdemEvent {}
