import 'package:equatable/equatable.dart';
import 'package:oficina_conectada_front/modules/dashboard/dashboard_model.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInicial extends DashboardState {}

class DashboardCarregando extends DashboardState {}

class DashboardCarregado extends DashboardState {
  final DashboardModel dados;

  const DashboardCarregado(this.dados);

  @override
  List<Object?> get props => [dados];
}

class DashboardErro extends DashboardState {
  final String mensagem;

  const DashboardErro(this.mensagem);

  @override
  List<Object?> get props => [mensagem];
}
