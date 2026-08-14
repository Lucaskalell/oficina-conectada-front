import 'package:equatable/equatable.dart';
import 'package:oficina_conectada_front/models/agendamento_model.dart';
import 'package:oficina_conectada_front/models/cliente_model.dart';
import 'package:oficina_conectada_front/models/mecanico_model.dart';

abstract class AgendamentoState extends Equatable {
  const AgendamentoState();

  @override
  List<Object?> get props => [];
}

class AgendamentoInicial extends AgendamentoState {}

class AgendamentoCarregando extends AgendamentoState {}

class AgendamentosCarregados extends AgendamentoState {
  final List<AgendamentoModel> agendamentos;
  const AgendamentosCarregados(this.agendamentos);

  @override
  List<Object?> get props => [agendamentos];
}

class DadosFormularioCarregados extends AgendamentoState {
  final List<ClienteModel> clientes;
  final List<MecanicoModel> mecanicos;
  const DadosFormularioCarregados(this.clientes, this.mecanicos);

  @override
  List<Object?> get props => [clientes, mecanicos];
}

class AgendamentoSalvo extends AgendamentoState {
  final String mensagem;
  const AgendamentoSalvo(this.mensagem);

  @override
  List<Object?> get props => [mensagem];
}

class AgendamentoErro extends AgendamentoState {
  final String mensagem;
  const AgendamentoErro(this.mensagem);

  @override
  List<Object?> get props => [mensagem];
}
