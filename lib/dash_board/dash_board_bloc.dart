import 'package:flutter_bloc/flutter_bloc.dart';
import 'dash_board_event.dart';
import 'dash_board_repository.dart';
import 'dash_board_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashBoardRepository repository;

  DashboardBloc(this.repository) : super(DashboardInitial()) {
    on<CarregarDashboard>((event, emit) async {
      emit(DashboardLoading());
      try {
        final dashboardData = await repository.getDashboardData();
        emit(DashboardLoaded(dashboardData));
      } catch (e) {
        emit(DashboardError('Erro ao carregar dashboard: $e'));
      }
    });
  }
}
