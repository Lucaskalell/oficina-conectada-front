import 'package:equatable/equatable.dart';

abstract class OrdensEvent extends Equatable {
  const OrdensEvent();

  @override
  List<Object?> get props => [];
}

class CarregarOrdens extends OrdensEvent {}

class DeletarOrdem extends OrdensEvent {
  final int id;

  const DeletarOrdem(this.id);

  @override
  List<Object?> get props => [id];
}
