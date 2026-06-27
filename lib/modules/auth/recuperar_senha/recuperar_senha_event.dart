import 'package:equatable/equatable.dart';

abstract class RecuperarSenhaEvent extends Equatable {
  const RecuperarSenhaEvent();

  @override
  List<Object?> get props => [];
}

class SolicitarToken extends RecuperarSenhaEvent {
  final String email;

  const SolicitarToken(this.email);

  @override
  List<Object?> get props => [email];
}

class RedefinirSenha extends RecuperarSenhaEvent {
  final String token;
  final String novaSenha;

  const RedefinirSenha({required this.token, required this.novaSenha});

  @override
  List<Object?> get props => [token, novaSenha];
}
