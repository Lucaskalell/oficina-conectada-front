part of 'login_controller.dart';

abstract class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object> get props => [];
}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {}

class LoginError extends LoginState {
  final String mensagem;
  const LoginError(this.mensagem);

  @override
  List<Object> get props => [mensagem];
}
