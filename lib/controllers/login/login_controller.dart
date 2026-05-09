import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:oficina_conectada_front/services/login_service.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginController extends Bloc<LoginEvent, LoginState> {
  final LoginService _loginService;

  LoginController(this._loginService) : super(LoginInitial()) {
    on<LoginBotaoPressionado>(_onLoginBotaoPressionado);
  }

  Future<void> _onLoginBotaoPressionado(
    LoginBotaoPressionado event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginLoading());
    try {
      await _loginService.login(event.email, event.senha);
      emit(LoginSuccess());
    } catch (e) {
      emit(LoginError(e.toString()));
    }
  }
}
