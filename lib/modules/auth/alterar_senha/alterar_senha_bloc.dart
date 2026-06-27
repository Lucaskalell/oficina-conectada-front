import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oficina_conectada_front/modules/auth/alterar_senha/alterar_senha_event.dart';
import 'package:oficina_conectada_front/modules/auth/alterar_senha/alterar_senha_service.dart';
import 'package:oficina_conectada_front/modules/auth/alterar_senha/alterar_senha_state.dart';

class AlterarSenhaBloc extends Bloc<AlterarSenhaEvent, AlterarSenhaState> {
  final AlterarSenhaService _alterarSenhaService;

  AlterarSenhaBloc(this._alterarSenhaService) : super(AlterarSenhaInicial()) {
    on<ConfirmarAlteracaoSenha>(_onConfirmarAlteracaoSenha);
  }

  Future<void> _onConfirmarAlteracaoSenha(
    ConfirmarAlteracaoSenha evento,
    Emitter<AlterarSenhaState> emit,
  ) async {
    emit(AlterarSenhaCarregando());
    try {
      await _alterarSenhaService.alterarSenha(evento.novaSenha);
      emit(AlterarSenhaSucesso());
    } catch (e) {
      emit(AlterarSenhaErro(e.toString()));
    }
  }
}
