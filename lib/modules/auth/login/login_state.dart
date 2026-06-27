import 'package:equatable/equatable.dart';

abstract class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object?> get props => [];
}

class LoginInicial extends LoginState {}

class LoginCarregando extends LoginState {}

class LoginSucesso extends LoginState {
  final bool primeiroAcesso;
  final String role;

  const LoginSucesso({required this.primeiroAcesso, required this.role});

  @override
  List<Object?> get props => [primeiroAcesso, role];
}

class LoginErro extends LoginState {
  final String mensagem;

  const LoginErro(this.mensagem);

  @override
  List<Object?> get props => [mensagem];
}
