
import '../../model/add_ordem_de_servico/ordem_de_servico_model.dart';

abstract class AdicionarOrdemEvent{}

class CriarOrdemDeServico extends AdicionarOrdemEvent {
  final OrdemDeServicoModel criarOrdemDeServico;
  CriarOrdemDeServico(this.criarOrdemDeServico);
}
class CarregarOrdemDeServico extends AdicionarOrdemEvent {}
