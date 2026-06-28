import 'package:equatable/equatable.dart';
import 'package:oficina_conectada_front/modules/ordens/ordens_model.dart';

abstract class OrdensState extends Equatable {
  const OrdensState();

  @override
  List<Object?> get props => [];
}

class OrdensInicial extends OrdensState {}

class OrdensCarregando extends OrdensState {}

class OrdensCarregadas extends OrdensState {
  final List<OrdemDeServicoModel> ordens;

  const OrdensCarregadas(this.ordens);

  @override
  List<Object?> get props => [ordens];
}

class OrdemDeletada extends OrdensState {}

class OrdensErro extends OrdensState {
  final String mensagem;

  const OrdensErro(this.mensagem);

  @override
  List<Object?> get props => [mensagem];
}
