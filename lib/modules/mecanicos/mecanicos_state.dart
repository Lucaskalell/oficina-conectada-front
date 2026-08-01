import 'package:equatable/equatable.dart';
import 'package:oficina_conectada_front/models/mecanico_model.dart';

abstract class MecanicosState extends Equatable {
  const MecanicosState();

  @override
  List<Object?> get props => [];
}

class MecanicosInicial extends MecanicosState {}

class MecanicosCarregando extends MecanicosState {}

class MecanicosCarregados extends MecanicosState {
  final List<MecanicoModel> mecanicos;
  const MecanicosCarregados(this.mecanicos);

  @override
  List<Object?> get props => [mecanicos];
}

class MecanicoSalvo extends MecanicosState {
  final String mensagem;
  const MecanicoSalvo(this.mensagem);

  @override
  List<Object?> get props => [mensagem];
}

class MecanicosErro extends MecanicosState {
  final String mensagem;
  const MecanicosErro(this.mensagem);

  @override
  List<Object?> get props => [mensagem];
}
