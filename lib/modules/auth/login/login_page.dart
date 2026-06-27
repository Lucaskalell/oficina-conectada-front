import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:oficina_conectada_front/modules/auth/login/login_bloc.dart';
import 'package:oficina_conectada_front/modules/auth/login/login_event.dart';
import 'package:oficina_conectada_front/modules/auth/login/login_service.dart';
import 'package:oficina_conectada_front/modules/auth/login/login_state.dart';
import 'package:oficina_conectada_front/core/constants/app_colors.dart';
import 'package:oficina_conectada_front/shared/widgets/custom_toast/custom_toast.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {


  late LoginBloc _loginBloc;
  late LoginService _loginService;
  late TextEditingController _emailController;
  late TextEditingController _senhaController;
  late FocusNode _emailFoco;
  late FocusNode _senhaFoco;


  bool _lembrarMe = false;
  bool _senhaVisivel = false;


  Future<void> _carregarCredenciais() async {
    final credenciais = await _loginService.carregarCredenciais();
    if (!mounted) return;
    setState(() {
      _emailController.text = credenciais['email'] ?? '';
      _senhaController.text = credenciais['senha'] ?? '';
      _lembrarMe = credenciais['lembrarMe'] == 'true';
    });
  }

  Future<void> _aoClicarEntrar() async {
    _emailFoco.unfocus();
    _senhaFoco.unfocus();

    if (_lembrarMe) {
      await _loginService.salvarCredenciais(
        _emailController.text,
        _senhaController.text,
      );
    } else {
      await _loginService.removerCredenciais();
    }

    _loginBloc.add(RealizarLogin(
      email: _emailController.text,
      senha: _senhaController.text,
    ));
  }

  void _alternarVisibilidadeSenha() {
    setState(() => _senhaVisivel = !_senhaVisivel);
  }

  void _aoClicarEsqueceuSenha() {
    Navigator.pushNamed(context, '/recuperar-senha');
  }


  @override
  void initState() {
    super.initState();
    _loginService = LoginService(const FlutterSecureStorage());
    _loginBloc = LoginBloc(_loginService);
    _emailController = TextEditingController();
    _senhaController = TextEditingController();
    _emailFoco = FocusNode();
    _senhaFoco = FocusNode();
    _carregarCredenciais();
  }


  Widget _construirTitulo() {
    return const Text(
      'OFICINA CONECTADA',
      style: TextStyle(
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _construirCampoEmail() {
    return TextField(
      controller: _emailController,
      focusNode: _emailFoco,
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
    );
  }

  Widget _construirCampoSenha() {
    return TextField(
      controller: _senhaController,
      focusNode: _senhaFoco,
      obscureText: !_senhaVisivel,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: 'Senha',
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: const Icon(Icons.lock_outline, color: Colors.white70),
        suffixIcon: IconButton(
          icon: Icon(
            _senhaVisivel ? Icons.visibility_off : Icons.visibility,
            color: Colors.white70,
          ),
          onPressed: _alternarVisibilidadeSenha,
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

  Widget _construirLembrarMe() {
    return CheckboxListTile(
      title: const Text(
        'Lembrar de mim',
        style: TextStyle(color: Colors.white70, fontSize: 14),
      ),
      value: _lembrarMe,
      onChanged: (bool? valor) => setState(() => _lembrarMe = valor ?? false),
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
      activeColor: AppColors.primaria,
      checkColor: Colors.white,
    );
  }

  Widget _construirBotaoEntrar() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaria,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: _aoClicarEntrar,
      child: const Text(
        'ENTRAR',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  Widget _construirBotaoEsqueceuSenha() {
    return TextButton(
      onPressed: _aoClicarEsqueceuSenha,
      child: const Text(
        'ESQUECEU SUA SENHA?',
        style: TextStyle(color: Colors.white70, fontSize: 12),
      ),
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
              const SizedBox(height: 32),
              _construirCampoEmail(),
              const SizedBox(height: 16),
              _construirCampoSenha(),
              _construirLembrarMe(),
              const SizedBox(height: 16),
              _construirBotaoEntrar(),
              const SizedBox(height: 8),
              _construirBotaoEsqueceuSenha(),
            ],
          ),
        ),
      ),
    );
  }


  Widget _blocBuilder() {
    return BlocConsumer<LoginBloc, LoginState>(
      bloc: _loginBloc,
      listener: (context, estado) {
        if (estado is LoginSucesso) {
          Navigator.pushReplacementNamed(context, '/home');
        }
        if (estado is LoginErro) {
          CustomToast.show(
            context,
            message: 'E-mail ou senha inválidos. Tente novamente.',
            type: ToastType.erro,
          );
        }
      },
      builder: (context, estado) {
        if (estado is LoginCarregando) {
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
    _loginBloc.close();
    _emailController.dispose();
    _senhaController.dispose();
    _emailFoco.dispose();
    _senhaFoco.dispose();
    super.dispose();
  }
}
