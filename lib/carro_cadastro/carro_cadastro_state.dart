import 'package:oficina_conectada_front/model/carro_model.dart';

abstract class CarroState {}

class CarroInitial extends CarroState {}

class CarroLoading extends CarroState {}

class CarroLoaded extends CarroState {
  final List<CarroStatusModel> carrosComStatus;

  CarroLoaded(this.carrosComStatus);
}

class CarroActionSuccess extends CarroState {
  final String mensagem;

  CarroActionSuccess(this.mensagem);
}

class CarroError extends CarroState {
  final String mensagem;

  CarroError(this.mensagem);
}
