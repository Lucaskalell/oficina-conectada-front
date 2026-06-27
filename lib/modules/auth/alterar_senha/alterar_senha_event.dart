import 'package:equatable/equatable.dart';

abstract class AlterarSenhaEvent extends Equatable {
  const AlterarSenhaEvent();

  @override
  List<Object?> get props => [];
}

class ConfirmarAlteracaoSenha extends AlterarSenhaEvent {
  final String novaSenha;

  const ConfirmarAlteracaoSenha(this.novaSenha);

  @override
  List<Object?> get props => [novaSenha];
}
