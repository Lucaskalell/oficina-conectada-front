import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oficina_conectada_front/modules/ordens/ordens_event.dart';
import 'package:oficina_conectada_front/modules/ordens/ordens_service.dart';
import 'package:oficina_conectada_front/modules/ordens/ordens_state.dart';

class OrdensBloc extends Bloc<OrdensEvent, OrdensState> {
  final OrdensService _ordensService;

  OrdensBloc(this._ordensService) : super(OrdensInicial()) {
    on<CarregarOrdens>(_onCarregarOrdens);
    on<DeletarOrdem>(_onDeletarOrdem);
  }

  Future<void> _onCarregarOrdens(
    CarregarOrdens evento,
    Emitter<OrdensState> emit,
  ) async {
    emit(OrdensCarregando());
    try {
      final ordens = await _ordensService.buscarOrdens();
      emit(OrdensCarregadas(ordens));
    } catch (e) {
      emit(OrdensErro(e.toString()));
    }
  }

  Future<void> _onDeletarOrdem(
    DeletarOrdem evento,
    Emitter<OrdensState> emit,
  ) async {
    try {
      await _ordensService.deletarOrdem(evento.id);
      emit(OrdemDeletada());
      final ordens = await _ordensService.buscarOrdens();
      emit(OrdensCarregadas(ordens));
    } catch (e) {
      emit(OrdensErro(e.toString()));
    }
  }
}
