import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oficina_conectada_front/modules/mecanicos/mecanicos_event.dart';
import 'package:oficina_conectada_front/modules/mecanicos/mecanicos_service.dart';
import 'package:oficina_conectada_front/modules/mecanicos/mecanicos_state.dart';

class MecanicosBloc extends Bloc<MecanicosEvent, MecanicosState> {
  final MecanicosService _mecanicosService;

  MecanicosBloc(this._mecanicosService) : super(MecanicosInicial()) {
    on<CarregarMecanicos>(_onCarregarMecanicos);
    on<CriarMecanico>(_onCriarMecanico);
    on<AtualizarMecanico>(_onAtualizarMecanico);
    on<DesativarMecanico>(_onDesativarMecanico);
  }

  Future<void> _onCarregarMecanicos(
    CarregarMecanicos evento,
    Emitter<MecanicosState> emit,
  ) async {
    emit(MecanicosCarregando());
    try {
      final mecanicos = await _mecanicosService.buscarMecanicos();
      emit(MecanicosCarregados(mecanicos));
    } catch (e) {
      emit(MecanicosErro(e.toString()));
    }
  }

  Future<void> _onCriarMecanico(
    CriarMecanico evento,
    Emitter<MecanicosState> emit,
  ) async {
    try {
      await _mecanicosService.criarMecanico(evento.mecanico);
      emit(const MecanicoSalvo('Mecânico cadastrado com sucesso'));
      add(CarregarMecanicos());
    } catch (e) {
      emit(MecanicosErro(e.toString()));
    }
  }

  Future<void> _onAtualizarMecanico(
    AtualizarMecanico evento,
    Emitter<MecanicosState> emit,
  ) async {
    try {
      await _mecanicosService.atualizarMecanico(evento.id, evento.dados);
      emit(const MecanicoSalvo('Mecânico atualizado com sucesso'));
      add(CarregarMecanicos());
    } catch (e) {
      emit(MecanicosErro(e.toString()));
    }
  }

  Future<void> _onDesativarMecanico(
    DesativarMecanico evento,
    Emitter<MecanicosState> emit,
  ) async {
    try {
      await _mecanicosService.desativarMecanico(evento.id);
      emit(const MecanicoSalvo('Mecânico desativado com sucesso'));
      add(CarregarMecanicos());
    } catch (e) {
      emit(MecanicosErro(e.toString()));
    }
  }
}
