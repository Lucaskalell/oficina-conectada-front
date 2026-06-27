import 'package:equatable/equatable.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object?> get props => [];
}

class RealizarLogin extends LoginEvent {
  final String email;
  final String senha;

  const RealizarLogin({required this.email, required this.senha});

  @override
  List<Object?> get props => [email, senha];
}
