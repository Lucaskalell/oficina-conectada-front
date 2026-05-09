import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oficina_conectada_front/services/dashboard_service.dart';
import 'package:oficina_conectada_front/controllers/dashboard/dashboard_event.dart';
import 'package:oficina_conectada_front/controllers/dashboard/dashboard_state.dart';

export 'package:oficina_conectada_front/controllers/dashboard/dashboard_event.dart';
export 'package:oficina_conectada_front/controllers/dashboard/dashboard_state.dart';

class DashboardController extends Bloc<DashboardEvent, DashboardState> {
  final DashboardService _service;

  DashboardController(this._service) : super(DashboardInitial()) {
    on<CarregarDashboard>((event, emit) async {
      emit(DashboardLoading());
      try {
        final dashboardData = await _service.getDashboardData();
        emit(DashboardLoaded(dashboardData));
      } catch (e) {
        emit(DashboardError('Erro ao carregar dashboard: $e'));
      }
    });
  }
}
