import 'package:flutter_bloc/flutter_bloc.dart';
import 'carro_cadastro_event.dart';
import 'carro_cadastro_repository.dart';
import 'carro_cadastro_state.dart';

class CarroBloc extends Bloc<CarroEvent, CarroState> {
  final CarroRepository _repository;

  CarroBloc(this._repository) : super(CarroInitial()) {

    on<CarregarCarros>((event, emit) async {
      emit(CarroLoading());
      try {
        final carros = await _repository.getCarrosComStatus();
        emit(CarroLoaded(carros));
      } catch (e) {
        emit(CarroError('Erro ao buscar veículos: $e'));
      }
    });

    on<CriarCarro>((event, emit) async {
      emit(CarroLoading());
      try {
        await _repository.criarCarro(event.carro);
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
        await _repository.atualizarCarro(event.id, event.carro);
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
        await _repository.deletarCarro(event.carroId);
        emit(CarroActionSuccess('Veículo excluído com sucesso!'));
        add(CarregarCarros());
      } catch (e) {
        emit(CarroError('Erro ao excluir veículo: $e'));
        add(CarregarCarros());
      }
    });
  }
}
