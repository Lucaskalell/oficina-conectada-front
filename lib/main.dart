import 'package:flutter/material.dart';
import 'package:oficina_conectada_front/home_page/home_page.dart';
import 'package:oficina_conectada_front/login/login_page.dart';
import 'carro_cadastro/carro_cadastro_page.dart';
import 'cliente_cadastro/cliente_page.dart';
import 'dash_board/dash_board_page.dart';
import 'estoque/estoque_page.dart';
import 'ordem_de_servico/ordem_de_servico_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Oficina Conectada',
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: const Color(0xFF121212)),
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
        '/estoque': (context) => const EstoquePage(),
        '/dashboard': (context) => const DashBoardPage(),
        '/ordemDeServico': (context) => const OrdemServicoPage(),
        '/cliente': (context) => const ClientesPage(),
        '/veiculo': (context) => const VeiculosPage(),
      },
    );
  }
}
