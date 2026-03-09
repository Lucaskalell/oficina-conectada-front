import '../model/model_dash_board/dash_board_model.dart';

abstract class DashboardState {}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final DashboardModel dados;

  DashboardLoaded(this.dados);
}

class DashboardError extends DashboardState {
  final String mensagem;

  DashboardError(this.mensagem);
}
