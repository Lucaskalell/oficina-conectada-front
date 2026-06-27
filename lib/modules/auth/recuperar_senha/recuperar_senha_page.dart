import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oficina_conectada_front/core/constants/app_colors.dart';
import 'package:oficina_conectada_front/modules/auth/recuperar_senha/recuperar_senha_bloc.dart';
import 'package:oficina_conectada_front/modules/auth/recuperar_senha/recuperar_senha_event.dart';
import 'package:oficina_conectada_front/modules/auth/recuperar_senha/recuperar_senha_service.dart';
import 'package:oficina_conectada_front/modules/auth/recuperar_senha/recuperar_senha_state.dart';
import 'package:oficina_conectada_front/shared/widgets/custom_toast/custom_toast.dart';

class RecuperarSenhaPage extends StatefulWidget {
  const RecuperarSenhaPage({super.key});

  @override
  State<RecuperarSenhaPage> createState() => _RecuperarSenhaPageState();
}

class _RecuperarSenhaPageState extends State<RecuperarSenhaPage> {


  late RecuperarSenhaBloc _recuperarSenhaBloc;
  late RecuperarSenhaService _recuperarSenhaService;
  late TextEditingController _emailController;
  late TextEditingController _tokenController;
  late TextEditingController _novaSenhaController;
  late TextEditingController _confirmarSenhaController;


  bool _etapaToken = false;
  bool _novaSenhaVisivel = false;
  bool _confirmarSenhaVisivel = false;


  void _aoClicarSolicitarToken() {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      CustomToast.show(context, message: 'Informe o e-mail.', type: ToastType.atencao);
      return;
    }
    _recuperarSenhaBloc.add(SolicitarToken(email));
  }

  void _aoClicarRedefinir() {
    final token = _tokenController.text.trim();
    final novaSenha = _novaSenhaController.text.trim();
    final confirmar = _confirmarSenhaController.text.trim();

    if (token.isEmpty) {
      CustomToast.show(context, message: 'Informe o código recebido.', type: ToastType.atencao);
      return;
    }
    if (novaSenha.length < 6) {
      CustomToast.show(context, message: 'A senha deve ter no mínimo 6 caracteres.', type: ToastType.atencao);
      return;
    }
    if (novaSenha != confirmar) {
      CustomToast.show(context, message: 'As senhas não coincidem.', type: ToastType.atencao);
      return;
    }

    _recuperarSenhaBloc.add(RedefinirSenha(token: token, novaSenha: novaSenha));
  }

  void _alternarNovaSenhaVisivel() {
    setState(() => _novaSenhaVisivel = !_novaSenhaVisivel);
  }

  void _alternarConfirmarSenhaVisivel() {
    setState(() => _confirmarSenhaVisivel = !_confirmarSenhaVisivel);
  }


  @override
  void initState() {
    super.initState();
    _recuperarSenhaService = RecuperarSenhaService();
    _recuperarSenhaBloc = RecuperarSenhaBloc(_recuperarSenhaService);
    _emailController = TextEditingController();
    _tokenController = TextEditingController();
    _novaSenhaController = TextEditingController();
    _confirmarSenhaController = TextEditingController();
  }


  Widget _construirTitulo() {
    return Column(
      children: [
        const Icon(Icons.email_outlined, color: AppColors.primaria, size: 48),
        const SizedBox(height: 16),
        Text(
          _etapaToken ? 'REDEFINIR SENHA' : 'RECUPERAR SENHA',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _etapaToken
              ? 'Insira o código recebido e sua nova senha.'
              : 'Informe seu e-mail para receber o código de recuperação.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
      ],
    );
  }

  Widget _construirEtapaEmail() {
    return Column(
      children: [
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'E-mail',
            labelStyle: const TextStyle(color: Colors.white70),
            prefixIcon: const Icon(Icons.email_outlined, color: Colors.white70),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaria,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: _aoClicarSolicitarToken,
          child: const Text('SOLICITAR CÓDIGO',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
      ],
    );
  }

  Widget _construirEtapaRedefinicao() {
    return Column(
      children: [
        TextField(
          controller: _tokenController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Código de Recuperação',
            labelStyle: const TextStyle(color: Colors.white70),
            prefixIcon: const Icon(Icons.vpn_key_outlined, color: Colors.white70),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _novaSenhaController,
          obscureText: !_novaSenhaVisivel,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Nova Senha',
            labelStyle: const TextStyle(color: Colors.white70),
            prefixIcon: const Icon(Icons.lock_outline, color: Colors.white70),
            suffixIcon: IconButton(
              icon: Icon(_novaSenhaVisivel ? Icons.visibility_off : Icons.visibility,
                  color: Colors.white70),
              onPressed: _alternarNovaSenhaVisivel,
            ),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _confirmarSenhaController,
          obscureText: !_confirmarSenhaVisivel,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Confirmar Senha',
            labelStyle: const TextStyle(color: Colors.white70),
            prefixIcon: const Icon(Icons.lock_outline, color: Colors.white70),
            suffixIcon: IconButton(
              icon: Icon(_confirmarSenhaVisivel ? Icons.visibility_off : Icons.visibility,
                  color: Colors.white70),
              onPressed: _alternarConfirmarSenhaVisivel,
            ),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaria,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: _aoClicarRedefinir,
          child: const Text('REDEFINIR SENHA',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
      ],
    );
  }

  Widget _construirBotaoVoltar() {
    return TextButton(
      onPressed: () => Navigator.pop(context),
      child: const Text('VOLTAR AO LOGIN',
          style: TextStyle(color: Colors.white70, fontSize: 12)),
    );
  }


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
              _etapaToken ? _construirEtapaRedefinicao() : _construirEtapaEmail(),
              const SizedBox(height: 8),
              _construirBotaoVoltar(),
            ],
          ),
        ),
      ),
    );
  }


  Widget _blocBuilder() {
    return BlocConsumer<RecuperarSenhaBloc, RecuperarSenhaState>(
      bloc: _recuperarSenhaBloc,
      listener: (context, estado) {
        if (estado is TokenEnviado) {
          setState(() {
            _etapaToken = true;
            _tokenController.text = estado.token;
          });
          CustomToast.show(context,
              message: 'Código gerado! Verifique o campo abaixo.',
              type: ToastType.sucesso);
        }
        if (estado is SenhaRedefinida) {
          CustomToast.show(context,
              message: 'Senha redefinida com sucesso!',
              type: ToastType.sucesso);
          Navigator.pushReplacementNamed(context, '/login');
        }
        if (estado is RecuperarSenhaErro) {
          CustomToast.show(context,
              message: estado.mensagem,
              type: ToastType.erro);
        }
      },
      builder: (context, estado) {
        if (estado is RecuperarSenhaCarregando) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }
        return _construirBody();
      },
    );
  }


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


  @override
  void dispose() {
    _recuperarSenhaBloc.close();
    _emailController.dispose();
    _tokenController.dispose();
    _novaSenhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }
}
