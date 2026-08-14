import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oficina_conectada_front/modules/agendamento/agendamento_event.dart';
import 'package:oficina_conectada_front/modules/agendamento/agendamento_service.dart';
import 'package:oficina_conectada_front/modules/agendamento/agendamento_state.dart';

class AgendamentoBloc extends Bloc<AgendamentoEvent, AgendamentoState> {
  final AgendamentoService _agendamentoService;

  AgendamentoBloc(this._agendamentoService) : super(AgendamentoInicial()) {
    on<CarregarAgendamentos>(_onCarregarAgendamentos);
    on<CarregarAgendamentosPorPeriodo>(_onCarregarAgendamentosPorPeriodo);
    on<CarregarDadosFormulario>(_onCarregarDadosFormulario);
    on<CriarAgendamento>(_onCriarAgendamento);
    on<AtualizarStatusAgendamento>(_onAtualizarStatusAgendamento);
    on<DeletarAgendamento>(_onDeletarAgendamento);
  }

  Future<void> _onCarregarAgendamentos(
    CarregarAgendamentos evento,
    Emitter<AgendamentoState> emit,
  ) async {
    emit(AgendamentoCarregando());
    try {
      final agendamentos = await _agendamentoService.buscarAgendamentos();
      emit(AgendamentosCarregados(agendamentos));
    } catch (e) {
      emit(AgendamentoErro(e.toString()));
    }
  }

  Future<void> _onCarregarAgendamentosPorPeriodo(
    CarregarAgendamentosPorPeriodo evento,
    Emitter<AgendamentoState> emit,
  ) async {
    emit(AgendamentoCarregando());
    try {
      final agendamentos = await _agendamentoService.buscarAgendamentosPorPeriodo(evento.inicio, evento.fim);
      emit(AgendamentosCarregados(agendamentos));
    } catch (e) {
      emit(AgendamentoErro(e.toString()));
    }
  }

  Future<void> _onCarregarDadosFormulario(
    CarregarDadosFormulario evento,
    Emitter<AgendamentoState> emit,
  ) async {
    try {
      final clientes = await _agendamentoService.buscarClientes();
      final mecanicos = await _agendamentoService.buscarMecanicosAtivos();
      emit(DadosFormularioCarregados(clientes, mecanicos));
    } catch (e) {
      emit(AgendamentoErro(e.toString()));
    }
  }

  Future<void> _onCriarAgendamento(
    CriarAgendamento evento,
    Emitter<AgendamentoState> emit,
  ) async {
    try {
      await _agendamentoService.criarAgendamento(evento.agendamento);
      emit(const AgendamentoSalvo('Agendamento criado com sucesso'));
      add(CarregarAgendamentos());
    } catch (e) {
      emit(AgendamentoErro(e.toString()));
    }
  }

  Future<void> _onAtualizarStatusAgendamento(
    AtualizarStatusAgendamento evento,
    Emitter<AgendamentoState> emit,
  ) async {
    try {
      await _agendamentoService.atualizarStatus(evento.id, evento.status);
      emit(const AgendamentoSalvo('Status atualizado com sucesso'));
      add(CarregarAgendamentos());
    } catch (e) {
      emit(AgendamentoErro(e.toString()));
    }
  }

  Future<void> _onDeletarAgendamento(
    DeletarAgendamento evento,
    Emitter<AgendamentoState> emit,
  ) async {
    try {
      await _agendamentoService.deletarAgendamento(evento.id);
      emit(const AgendamentoSalvo('Agendamento excluído com sucesso'));
      add(CarregarAgendamentos());
    } catch (e) {
      emit(AgendamentoErro(e.toString()));
    }
  }
}
