import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oficina_conectada_front/modules/auth/login/login_event.dart';
import 'package:oficina_conectada_front/modules/auth/login/login_service.dart';
import 'package:oficina_conectada_front/modules/auth/login/login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginService _loginService;

  LoginBloc(this._loginService) : super(LoginInicial()) {
    on<RealizarLogin>(_onRealizarLogin);
  }

  Future<void> _onRealizarLogin(
    RealizarLogin evento,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginCarregando());
    try {
      await _loginService.realizarLogin(evento.email, evento.senha);
      emit(LoginSucesso());
    } catch (e) {
      emit(LoginErro(e.toString()));
    }
  }
}
