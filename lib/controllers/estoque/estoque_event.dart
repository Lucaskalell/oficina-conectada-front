part of 'estoque_controller.dart';

abstract class EstoqueEvent extends Equatable {
  const EstoqueEvent();

  @override
  List<Object?> get props => [];
}

class BuscarCategoriasIniciado extends EstoqueEvent {}

class BuscarResumoIniciado extends EstoqueEvent {}
