import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oficina_conectada_front/modules/dashboard/dashboard_event.dart';
import 'package:oficina_conectada_front/modules/dashboard/dashboard_service.dart';
import 'package:oficina_conectada_front/modules/dashboard/dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardService _dashboardService;

  DashboardBloc(this._dashboardService) : super(DashboardInicial()) {
    on<CarregarDashboard>(_onCarregarDashboard);
  }

  Future<void> _onCarregarDashboard(
    CarregarDashboard evento,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardCarregando());
    try {
      final dados = await _dashboardService.buscarDados();
      emit(DashboardCarregado(dados));
    } catch (e) {
      emit(DashboardErro('Erro ao carregar dashboard: $e'));
    }
  }
}
