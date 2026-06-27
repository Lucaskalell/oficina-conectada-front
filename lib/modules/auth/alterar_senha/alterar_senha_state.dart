import 'package:equatable/equatable.dart';

abstract class AlterarSenhaState extends Equatable {
  const AlterarSenhaState();

  @override
  List<Object?> get props => [];
}

class AlterarSenhaInicial extends AlterarSenhaState {}

class AlterarSenhaCarregando extends AlterarSenhaState {}

class AlterarSenhaSucesso extends AlterarSenhaState {}

class AlterarSenhaErro extends AlterarSenhaState {
  final String mensagem;

  const AlterarSenhaErro(this.mensagem);

  @override
  List<Object?> get props => [mensagem];
}
