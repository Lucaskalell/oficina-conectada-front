import 'package:equatable/equatable.dart';
import 'package:oficina_conectada_front/models/agendamento_model.dart';

abstract class AgendamentoEvent extends Equatable {
  const AgendamentoEvent();

  @override
  List<Object?> get props => [];
}

class CarregarAgendamentos extends AgendamentoEvent {}

class CarregarAgendamentosPorPeriodo extends AgendamentoEvent {
  final DateTime inicio;
  final DateTime fim;
  const CarregarAgendamentosPorPeriodo(this.inicio, this.fim);

  @override
  List<Object?> get props => [inicio, fim];
}

class CarregarDadosFormulario extends AgendamentoEvent {}

class CriarAgendamento extends AgendamentoEvent {
  final AgendamentoModel agendamento;
  const CriarAgendamento(this.agendamento);

  @override
  List<Object?> get props => [agendamento];
}

class AtualizarStatusAgendamento extends AgendamentoEvent {
  final int id;
  final String status;
  const AtualizarStatusAgendamento(this.id, this.status);

  @override
  List<Object?> get props => [id, status];
}

class DeletarAgendamento extends AgendamentoEvent {
  final int id;
  const DeletarAgendamento(this.id);

  @override
  List<Object?> get props => [id];
}
