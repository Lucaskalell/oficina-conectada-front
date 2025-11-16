import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:oficina_conectada_front/login/login_repository.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginRepository _loginRepository;
  LoginBloc(this._loginRepository) : super(LoginInitial()) {
    on<LoginBotaoPressionado>(_onLoginBotaoPressionado);
  }

  Future<void> _onLoginBotaoPressionado(
    LoginBotaoPressionado event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginLoading());
    try {
      await _loginRepository.login(event.email, event.senha);
      emit(LoginSuccess());
    } catch (e) {
      emit(LoginError(e.toString()));
    }
  }
}
