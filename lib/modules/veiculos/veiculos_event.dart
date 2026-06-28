import 'package:equatable/equatable.dart';
import 'package:oficina_conectada_front/models/carro_model.dart';

abstract class VeiculosEvent extends Equatable {
  const VeiculosEvent();

  @override
  List<Object?> get props => [];
}

class CarregarVeiculos extends VeiculosEvent {}

class CriarVeiculo extends VeiculosEvent {
  final CarroModel carro;
  const CriarVeiculo(this.carro);

  @override
  List<Object?> get props => [carro];
}

class DeletarVeiculo extends VeiculosEvent {
  final int id;
  const DeletarVeiculo(this.id);

  @override
  List<Object?> get props => [id];
}
