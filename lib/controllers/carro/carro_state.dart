import 'package:equatable/equatable.dart';
import 'package:oficina_conectada_front/models/carro_model.dart';

abstract class CarroState extends Equatable {
  const CarroState();

  @override
  List<Object?> get props => [];
}

class CarroInitial extends CarroState {}

class CarroLoading extends CarroState {}

class CarroLoaded extends CarroState {
  final List<CarroStatusModel> carros;
  const CarroLoaded(this.carros);

  @override
  List<Object?> get props => [carros];
}

class CarroActionSuccess extends CarroState {
  final String message;
  const CarroActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class CarroError extends CarroState {
  final String message;
  const CarroError(this.message);

  @override
  List<Object?> get props => [message];
}
