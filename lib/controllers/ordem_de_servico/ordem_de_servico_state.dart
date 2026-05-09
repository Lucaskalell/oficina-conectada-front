import 'package:oficina_conectada_front/models/ordem_de_servico_model.dart';

abstract class OrdemDeServicoState {}

class OrdemDeServicoInitialState extends OrdemDeServicoState {}

class OrdemDeServicoLoadingState extends OrdemDeServicoState {}

class OrdemDeServicoLoadingDeleteState extends OrdemDeServicoState {}

class OrdemDeServicoSuccessState extends OrdemDeServicoState {
  final OrdemDeServicoModel ordemDeServico;
  OrdemDeServicoSuccessState(this.ordemDeServico);
}

class OrdemDeServicoListSuccessState extends OrdemDeServicoState {
  final List<OrdemDeServicoModel> ordensDeServico;
  OrdemDeServicoListSuccessState(this.ordensDeServico);
}

class OrdemDeServicoDeletadaComSucesso extends OrdemDeServicoState {
  final String message;
  OrdemDeServicoDeletadaComSucesso(this.message);
}

class OrdemDeServicoErrorState extends OrdemDeServicoState {
  final String message;
  OrdemDeServicoErrorState(this.message);
}
