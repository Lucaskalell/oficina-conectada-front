import 'package:equatable/equatable.dart';
import 'package:oficina_conectada_front/models/mecanico_model.dart';

abstract class MecanicosEvent extends Equatable {
  const MecanicosEvent();

  @override
  List<Object?> get props => [];
}

class CarregarMecanicos extends MecanicosEvent {}

class CriarMecanico extends MecanicosEvent {
  final MecanicoModel mecanico;
  const CriarMecanico(this.mecanico);

  @override
  List<Object?> get props => [mecanico];
}

class AtualizarMecanico extends MecanicosEvent {
  final int id;
  final MecanicoModel dados;
  const AtualizarMecanico(this.id, this.dados);

  @override
  List<Object?> get props => [id, dados];
}

class DesativarMecanico extends MecanicosEvent {
  final int id;
  const DesativarMecanico(this.id);

  @override
  List<Object?> get props => [id];
}
