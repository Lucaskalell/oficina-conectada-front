part of 'login_bloc.dart';
abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object> get props => [];
}

class LoginBotaoPressionado extends LoginEvent {
  final String email;
  final String senha;

  const LoginBotaoPressionado({required this.email, required this.senha});

  @override
  List<Object> get props => [email, senha];
}
