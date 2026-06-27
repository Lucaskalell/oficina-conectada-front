import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oficina_conectada_front/core/constants/app_colors.dart';
import 'package:oficina_conectada_front/modules/auth/alterar_senha/alterar_senha_bloc.dart';
import 'package:oficina_conectada_front/modules/auth/alterar_senha/alterar_senha_event.dart';
import 'package:oficina_conectada_front/modules/auth/alterar_senha/alterar_senha_service.dart';
import 'package:oficina_conectada_front/modules/auth/alterar_senha/alterar_senha_state.dart';
import 'package:oficina_conectada_front/shared/widgets/custom_toast/custom_toast.dart';

class AlterarSenhaPage extends StatefulWidget {
  const AlterarSenhaPage({super.key});

  @override
  State<AlterarSenhaPage> createState() => _AlterarSenhaPageState();
}

class _AlterarSenhaPageState extends State<AlterarSenhaPage> {

// ========= BLOC / INSTÂNCIAS / CONTROLLERS =========

  late AlterarSenhaBloc _alterarSenhaBloc;
  late AlterarSenhaService _alterarSenhaService;
  late TextEditingController _novaSenhaController;
  late TextEditingController _confirmarSenhaController;

// ========= VARIÁVEIS =========

  bool _novaSenhaVisivel = false;
  bool _confirmarSenhaVisivel = false;

// ========= FUNÇÕES =========

  void _aoClicarConfirmar() {
    final novaSenha = _novaSenhaController.text.trim();
    final confirmar = _confirmarSenhaController.text.trim();

    if (novaSenha.length < 6) {
      CustomToast.show(context,
          message: 'A senha deve ter no mínimo 6 caracteres.',
          type: ToastType.atencao);
      return;
    }

    if (novaSenha != confirmar) {
      CustomToast.show(context,
          message: 'As senhas não coincidem.',
          type: ToastType.atencao);
      return;
    }

    _alterarSenhaBloc.add(ConfirmarAlteracaoSenha(novaSenha));
  }

  void _alternarVisibilidadeNovaSenha() {
    setState(() => _novaSenhaVisivel = !_novaSenhaVisivel);
  }

  void _alternarVisibilidadeConfirmar() {
    setState(() => _confirmarSenhaVisivel = !_confirmarSenhaVisivel);
  }

// ========= INIT STATE =========

  @override
  void initState() {
    super.initState();
    _alterarSenhaService = AlterarSenhaService();
    _alterarSenhaBloc = AlterarSenhaBloc(_alterarSenhaService);
    _novaSenhaController = TextEditingController();
    _confirmarSenhaController = TextEditingController();
  }

// ========= COMPONENTES DA TELA =========

  Widget _construirTitulo() {
    return Column(
      children: const [
        Icon(Icons.lock_reset, color: AppColors.primaria, size: 48),
        SizedBox(height: 16),
        Text(
          'DEFINA SUA SENHA',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Este é seu primeiro acesso.\nCrie uma senha segura para continuar.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70, fontSize: 13),
        ),
      ],
    );
  }

  Widget _construirCampoNovaSenha() {
    return TextField(
      controller: _novaSenhaController,
      obscureText: !_novaSenhaVisivel,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: 'Nova Senha',
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: const Icon(Icons.lock_outline, color: Colors.white70),
        suffixIcon: IconButton(
          icon: Icon(
            _novaSenhaVisivel ? Icons.visibility_off : Icons.visibility,
            color: Colors.white70,
          ),
          onPressed: _alternarVisibilidadeNovaSenha,
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _construirCampoConfirmarSenha() {
    return TextField(
      controller: _confirmarSenhaController,
      obscureText: !_confirmarSenhaVisivel,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: 'Confirmar Senha',
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: const Icon(Icons.lock_outline, color: Colors.white70),
        suffixIcon: IconButton(
          icon: Icon(
            _confirmarSenhaVisivel ? Icons.visibility_off : Icons.visibility,
            color: Colors.white70,
          ),
          onPressed: _alternarVisibilidadeConfirmar,
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _construirBotaoConfirmar() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaria,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: _aoClicarConfirmar,
      child: const Text(
        'CONFIRMAR',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

// ========= BODY =========

  Widget _construirBody() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: 350,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _construirTitulo(),
              const SizedBox(height: 28),
              _construirCampoNovaSenha(),
              const SizedBox(height: 16),
              _construirCampoConfirmarSenha(),
              const SizedBox(height: 24),
              _construirBotaoConfirmar(),
            ],
          ),
        ),
      ),
    );
  }

// ========= BLOC BUILDER =========

  Widget _blocBuilder() {
    return BlocConsumer<AlterarSenhaBloc, AlterarSenhaState>(
      bloc: _alterarSenhaBloc,
      listener: (context, estado) {
        if (estado is AlterarSenhaSucesso) {
          CustomToast.show(context,
              message: 'Senha alterada com sucesso!',
              type: ToastType.sucesso);
          Navigator.pushReplacementNamed(context, '/home');
        }
        if (estado is AlterarSenhaErro) {
          CustomToast.show(context,
              message: 'Erro ao alterar senha. Tente novamente.',
              type: ToastType.erro);
        }
      },
      builder: (context, estado) {
        if (estado is AlterarSenhaCarregando) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }
        return _construirBody();
      },
    );
  }

// ========= BUILD =========

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/login.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(child: _blocBuilder()),
      ),
    );
  }

// ========= DISPOSE =========

  @override
  void dispose() {
    _alterarSenhaBloc.close();
    _novaSenhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }
}
