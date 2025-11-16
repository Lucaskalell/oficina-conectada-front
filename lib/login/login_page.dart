import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oficina_conectada_front/login/login_bloc.dart';
import 'package:oficina_conectada_front/login/login_repository.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late LoginBloc _loginBloc;
  late TextEditingController _emailController;
  late TextEditingController _senhaController;

  final FocusNode _emailFocus = FocusNode();
  final FocusNode _senhaFocus = FocusNode();

  void _handleLoginClick() {
    _emailFocus.unfocus();
    _senhaFocus.unfocus();

    _loginBloc.add(
      LoginBotaoPressionado(
        email: _emailController.text,
        senha: _senhaController.text,
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  void initState() {
    super.initState();
    _loginBloc = LoginBloc(LoginRepository());
    _emailController = TextEditingController();
    _senhaController = TextEditingController();
  }

  Widget _buildTitle() {
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

  Widget _buildEmailField() {
    return TextField(
      controller: _emailController,
      focusNode: _emailFocus,
      decoration: InputDecoration(
        labelText: 'E-mail',
        labelStyle: const TextStyle(color: Colors.white),
        prefixIcon: const Icon(Icons.email_outlined, color: Colors.white),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
      style: const TextStyle(color: Colors.white),
      keyboardType: TextInputType.emailAddress,
    );
  }

  Widget _buildSenhaField() {
    return TextField(
      controller: _senhaController,
      focusNode: _senhaFocus,
      decoration: InputDecoration(
        labelText: 'Senha',
        labelStyle: const TextStyle(color: Colors.white),
        prefixIcon: const Icon(Icons.lock_outline, color: Colors.white),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
      style: const TextStyle(color: Colors.white),
      obscureText: true,
    );
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 16),
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: _handleLoginClick,
      child: const Text(
        'ENTRAR',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  Widget _buildForgotPasswordButton() {
    return TextButton(
      onPressed: () {
        // TODO: kalello não esuqecer logica aqui mermao "Esqueci a senha"
      },
      child: const Text(
        'ESQUECEU SUA SENHA?',
        style: TextStyle(color: Colors.white70, fontSize: 12),
      ),
    );
  }

  Widget _buildBody() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: 350,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTitle(),
              const SizedBox(height: 32),
              _buildEmailField(),
              const SizedBox(height: 16),
              _buildSenhaField(),
              const SizedBox(height: 32),
              _buildLoginButton(),
              const SizedBox(height: 16),
              _buildForgotPasswordButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _blocBuilder() {
    return BlocConsumer<LoginBloc, LoginState>(
      bloc: _loginBloc,
      listener: (context, state) {
        if (state is LoginSuccess) {
          Navigator.pushReplacementNamed(context, '/home');
        }
        if (state is LoginError) {
          _showError(state.mensagem);
        }
      },
      builder: (context, state) {
        switch (state.runtimeType) {
          case LoginLoading:
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );

          case LoginInitial:
          case LoginError:
          case LoginSuccess:
          default:
            return _buildBody();
        }
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
    _emailFocus.dispose();
    _senhaFocus.dispose();
    super.dispose();
  }
}