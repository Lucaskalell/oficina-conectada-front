import 'package:equatable/equatable.dart';

abstract class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object?> get props => [];
}

class LoginInicial extends LoginState {}

class LoginCarregando extends LoginState {}

class LoginSucesso extends LoginState {}

class LoginErro extends LoginState {
  final String mensagem;

  const LoginErro(this.mensagem);

  @override
  List<Object?> get props => [mensagem];
}
