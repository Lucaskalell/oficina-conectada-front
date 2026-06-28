import 'package:equatable/equatable.dart';
import 'package:oficina_conectada_front/models/carro_model.dart';

abstract class VeiculosState extends Equatable {
  const VeiculosState();

  @override
  List<Object?> get props => [];
}

class VeiculosInicial extends VeiculosState {}

class VeiculosCarregando extends VeiculosState {}

class VeiculosCarregados extends VeiculosState {
  final List<CarroStatusModel> veiculos;
  const VeiculosCarregados(this.veiculos);

  @override
  List<Object?> get props => [veiculos];
}

class VeiculoCriado extends VeiculosState {}

class VeiculoDeletado extends VeiculosState {}

class VeiculosErro extends VeiculosState {
  final String mensagem;
  const VeiculosErro(this.mensagem);

  @override
  List<Object?> get props => [mensagem];
}
