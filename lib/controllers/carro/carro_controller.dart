import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oficina_conectada_front/services/carro_service.dart';
import 'package:oficina_conectada_front/controllers/carro/carro_event.dart';
import 'package:oficina_conectada_front/controllers/carro/carro_state.dart';

export 'package:oficina_conectada_front/controllers/carro/carro_event.dart';
export 'package:oficina_conectada_front/controllers/carro/carro_state.dart';

class CarroController extends Bloc<CarroEvent, CarroState> {
  final CarroService _service;

  CarroController(this._service) : super(CarroInitial()) {
    on<CarregarCarros>((event, emit) async {
      emit(CarroLoading());
      try {
        final carros = await _service.getCarrosComStatus();
        emit(CarroLoaded(carros));
      } catch (e) {
        emit(CarroError('Erro ao buscar veículos: $e'));
      }
    });

    on<CriarCarro>((event, emit) async {
      emit(CarroLoading());
      try {
        await _service.criarCarro(event.carro);
        emit(CarroActionSuccess('Veículo cadastrado com sucesso!'));
        add(CarregarCarros());
      } catch (e) {
        emit(CarroError('Erro ao cadastrar veículo: $e'));
        add(CarregarCarros());
      }
    });

    on<AtualizarCarro>((event, emit) async {
      emit(CarroLoading());
      try {
        await _service.atualizarCarro(event.id, event.carro);
        emit(CarroActionSuccess('Veículo atualizado com sucesso!'));
        add(CarregarCarros());
      } catch (e) {
        emit(CarroError('Erro ao atualizar veículo: $e'));
        add(CarregarCarros());
      }
    });

    on<DeletarCarro>((event, emit) async {
      emit(CarroLoading());
      try {
        await _service.deletarCarro(event.carroId);
        emit(CarroActionSuccess('Veículo excluído com sucesso!'));
        add(CarregarCarros());
      } catch (e) {
        emit(CarroError('Erro ao excluir veículo: $e'));
        add(CarregarCarros());
      }
    });
  }
}
