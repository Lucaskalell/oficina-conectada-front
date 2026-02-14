import 'package:oficina_conectada_front/ordem_de_servico/model/ordem_de_servico_model.dart';

abstract class AdicionarOrdemState {}

class AdicionarOrdemInitialState extends AdicionarOrdemState {}

class AdiconaroOrdemLoadingState extends AdicionarOrdemState {}



class AdicionarOrdemSuccessState extends AdicionarOrdemState {
  final OrdemDeServicoModel ordemServico;
  AdicionarOrdemSuccessState(this.ordemServico);
}



class AdicionarOrdemErrorState extends AdicionarOrdemState {
  final String message;
  AdicionarOrdemErrorState(this.message);
}
