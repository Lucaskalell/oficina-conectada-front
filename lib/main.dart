import 'package:flutter/material.dart';
import 'package:oficina_conectada_front/modules/auth/login/login_page.dart';
import 'package:oficina_conectada_front/modules/auth/alterar_senha/alterar_senha_page.dart';
import 'package:oficina_conectada_front/modules/auth/recuperar_senha/recuperar_senha_page.dart';
import 'package:oficina_conectada_front/views/home/home_view.dart';
import 'package:oficina_conectada_front/modules/veiculos/veiculos_page.dart';
import 'package:oficina_conectada_front/modules/mecanicos/mecanicos_page.dart';
import 'package:oficina_conectada_front/modules/clientes/clientes_page.dart';
import 'package:oficina_conectada_front/modules/dashboard/dashboard_page.dart';
import 'package:oficina_conectada_front/modules/estoque/estoque_page.dart';
import 'package:oficina_conectada_front/modules/ordens/ordens_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Oficina Conectada',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/alterar-senha': (context) => const AlterarSenhaPage(),
        '/recuperar-senha': (context) => const RecuperarSenhaPage(),
        '/home': (context) => const HomeView(),
        '/estoque': (context) => const EstoquePage(),
        '/dashboard': (context) => const DashboardPage(),
        '/ordemDeServico': (context) => const OrdensPage(),
        '/cliente': (context) => const ClientesPage(),
        '/veiculo': (context) => const VeiculosPage(),
        '/mecanico': (context) => const MecanicosPage(),
      },
    );
  }
}
