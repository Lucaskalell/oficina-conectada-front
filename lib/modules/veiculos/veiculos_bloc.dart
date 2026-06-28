import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oficina_conectada_front/modules/veiculos/veiculos_event.dart';
import 'package:oficina_conectada_front/modules/veiculos/veiculos_service.dart';
import 'package:oficina_conectada_front/modules/veiculos/veiculos_state.dart';

class VeiculosBloc extends Bloc<VeiculosEvent, VeiculosState> {
  final VeiculosService _veiculosService;

  VeiculosBloc(this._veiculosService) : super(VeiculosInicial()) {
    on<CarregarVeiculos>(_onCarregarVeiculos);
    on<CriarVeiculo>(_onCriarVeiculo);
    on<DeletarVeiculo>(_onDeletarVeiculo);
  }

  Future<void> _onCarregarVeiculos(
    CarregarVeiculos evento,
    Emitter<VeiculosState> emit,
  ) async {
    emit(VeiculosCarregando());
    try {
      final veiculos = await _veiculosService.buscarVeiculosComStatus();
      emit(VeiculosCarregados(veiculos));
    } catch (e) {
      emit(VeiculosErro(e.toString()));
    }
  }

  Future<void> _onCriarVeiculo(
    CriarVeiculo evento,
    Emitter<VeiculosState> emit,
  ) async {
    emit(VeiculosCarregando());
    try {
      await _veiculosService.criarVeiculo(evento.carro);
      emit(VeiculoCriado());
      add(CarregarVeiculos());
    } catch (e) {
      emit(VeiculosErro(e.toString()));
    }
  }

  Future<void> _onDeletarVeiculo(
    DeletarVeiculo evento,
    Emitter<VeiculosState> emit,
  ) async {
    try {
      await _veiculosService.deletarVeiculo(evento.id);
      emit(VeiculoDeletado());
      add(CarregarVeiculos());
    } catch (e) {
      emit(VeiculosErro(e.toString()));
    }
  }
}
