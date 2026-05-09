import 'package:equatable/equatable.dart';
import 'package:oficina_conectada_front/models/carro_model.dart';

abstract class CarroEvent extends Equatable {
  const CarroEvent();

  @override
  List<Object?> get props => [];
}

class CarregarCarros extends CarroEvent {}

class CriarCarro extends CarroEvent {
  final CarroModel carro;
  const CriarCarro(this.carro);

  @override
  List<Object?> get props => [carro];
}

class AtualizarCarro extends CarroEvent {
  final int id;
  final CarroModel carro;
  const AtualizarCarro(this.id, this.carro);

  @override
  List<Object?> get props => [id, carro];
}

class DeletarCarro extends CarroEvent {
  final int carroId;
  const DeletarCarro(this.carroId);

  @override
  List<Object?> get props => [carroId];
}
