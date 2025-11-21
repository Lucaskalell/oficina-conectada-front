import 'package:flutter/material.dart';
import 'package:oficina_conectada_front/home_page/home_page.dart';
import 'package:oficina_conectada_front/login/login_page.dart';

import 'estoque/estoque_page.dart';
import 'estoque/sub_categoria/sub_categoria_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Oficina Conectada',
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',

      routes: {
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
        '/estoque': (context) => const EstoquePage(),
      },
    );
  }
}