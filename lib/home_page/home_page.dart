import 'package:flutter/material.dart';
import 'package:oficina_conectada_front/cliente_cadastro/cliente_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:oficina_conectada_front/dash_board/dash_board_page.dart';
import 'package:oficina_conectada_front/estoque/estoque_page.dart';
import 'package:oficina_conectada_front/ordem_de_servico/ordem_de_servico_page.dart';

import '../carro_cadastro/carro_cadastro_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = -1;
  String _currentTitle = 'Oficina do Tomioka';

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Cores Padrão Vercel
  final Color _bgDark = const Color(0xFF09090B); //  (Fundo Geral)
  final Color _sidebarDark = const Color(0xFF000000); // Preto absoluto ou 09090B
  final Color _cardDark = const Color(0xFF18181B); // (Itens selecionados)
  final Color _primaryColor = const Color(0xFF10B981); // Verde Esmeralda
  final Color _textForeground = const Color(0xFFFAFAFA); // Branco
  final Color _textMuted = const Color(0xFFA1A1AA); // Cinza texto

  // Expandi a lista de futuras melhorias que vou colocar
  final List<Widget> _screens = [
    const DashBoardPage(), // 0
    const OrdemServicoPage(), // 1
    const ClientesPage(), // 2
    const VeiculosPage(),// 3
    const EstoquePage(), // 4
    const Center(child: Text('Página: Financeiro', style: TextStyle(fontSize: 24, color: Colors.grey))), // 5
    const Center(child: Text('Página: Agenda', style: TextStyle(fontSize: 24, color: Colors.grey))), // 6
    const Center(child: Text('Página: Chat', style: TextStyle(fontSize: 24, color: Colors.grey))), // 7
    const Center(child: Text('Página: Configuração', style: TextStyle(fontSize: 24, color: Colors.grey))), // 8
  ];

  void _onScreenSelected(int index, String titulo) {
    setState(() {
      _selectedIndex = index;
      _currentTitle = titulo;
    });
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.of(context).pop();
    }
  }

  void _resetToHome() {
    setState(() {
      _selectedIndex = -1;
      _currentTitle = 'Oficina do Tomioka';
    });
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(_currentTitle, style: TextStyle(color: _textForeground, fontSize: 18, fontWeight: FontWeight.w600)),
      backgroundColor: _bgDark,
      elevation: 0,
      iconTheme: IconThemeData(color: _textMuted),
      shape: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05), width: 1)),
      actions: [
        IconButton(
          icon: Icon(Icons.notifications_none_outlined, color: _textMuted),
          tooltip: 'Notificações',
          splashRadius: 20,
          onPressed: () {},
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Nova OS', style: TextStyle(fontWeight: FontWeight.w600)),
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            onPressed: () {
              Navigator.of(context).pushNamed('/ordemDeServico');
            },
          ),
        ),
        const SizedBox(width: 8),
        _buildProfileAvatar(),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildProfileAvatar() {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'sair') _handleLogout();
      },
      tooltip: 'Opções da Conta',
      color: _cardDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: Colors.white.withOpacity(0.1))),
      child: CircleAvatar(
        radius: 16,
        backgroundImage: const AssetImage('assets/images/tomioka.png'),
        backgroundColor: _cardDark,
      ),
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'perfil',
          child: Text('Ver Perfil', style: TextStyle(color: Colors.white)),
        ),
        const PopupMenuItem<String>(
          value: 'sair',
          child: Text('Sair', style: TextStyle(color: Colors.redAccent)),
        ),
      ],
    );
  }

  Widget _buildDrawer() {
    return Container(
      width: 260,
      color: _sidebarDark,
      child: Column(
        children: [
          // Header do Menu (Logo + Nome do Sistema)
          InkWell(
            onTap: _resetToHome,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _primaryColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.build, color: _primaryColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Oficina Conectada', style: TextStyle(color: _textForeground, fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('Sistema de Gerenciamento', style: TextStyle(color: _textMuted, fontSize: 12)),
                    ],
                  )
                ],
              ),
            ),
          ),

          Divider(color: Colors.white.withOpacity(0.05), height: 1),

          // Menu de Navegação
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              children: [
                _buildSectionTitle('PRINCIPAL'),
                _buildNavItem(0, 'Dashboard', Icons.grid_view_rounded),
                _buildNavItem(1, 'Ordens de Serviço', Icons.assignment_outlined, badge: 12),
                _buildNavItem(2, 'Clientes', Icons.people_outline),
                _buildNavItem(3, 'Veículos', Icons.directions_car_outlined),
                _buildNavItem(4, 'Estoque', Icons.inventory_2_outlined, badge: 3),
                _buildNavItem(5, 'Financeiro', Icons.attach_money_outlined),
                _buildNavItem(6, 'Agenda', Icons.calendar_today_outlined),
                _buildNavItem(7, 'Chat', Icons.chat_bubble_outline),

                const SizedBox(height: 16),
                _buildSectionTitle('SISTEMA'),
                _buildNavItem(8, 'Configurações', Icons.settings_outlined),
              ],
            ),
          ),

          // Perfil do Usuário
          Divider(color: Colors.white.withOpacity(0.05), height: 1),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage: const AssetImage('assets/images/tomioka.png'),
                  backgroundColor: _cardDark,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Kalell', style: TextStyle(color: _textForeground, fontSize: 14, fontWeight: FontWeight.w500)),
                      Text('lucas@email.com', style: TextStyle(color: _textMuted, fontSize: 12), overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.redAccent, size: 20),
                  onPressed: _handleLogout,
                  splashRadius: 20,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  // auxiliares para o Menu
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
      child: Text(
        title,
        style: TextStyle(color: _textMuted.withOpacity(0.5), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2),
      ),
    );
  }

  Widget _buildNavItem(int index, String title, IconData icon, {int? badge}) {
    final bool isSelected = _selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        dense: true,
        leading: Icon(icon, color: isSelected ? _textForeground : _textMuted, size: 20),
        title: Text(
            title,
            style: TextStyle(color: isSelected ? _textForeground : _textMuted, fontSize: 14, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal)
        ),
        tileColor: isSelected ? _cardDark : Colors.transparent,
        hoverColor: _cardDark.withOpacity(0.5),
        trailing: badge != null
            ? Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(color: _primaryColor.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
          child: Text(badge.toString(), style: TextStyle(color: _primaryColor, fontSize: 11, fontWeight: FontWeight.bold)),
        )
            : null,
        onTap: () => _onScreenSelected(index, title),
      ),
    );
  }

  Widget _buildBody() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _selectedIndex == -1
          ? Container(
        key: const ValueKey('HomeImage'),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/testehome.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [Colors.black.withOpacity(0.9), Colors.transparent],
            ),
          ),
          alignment: Alignment.bottomLeft,
          padding: const EdgeInsets.all(40),
          child: const Text(
            'Bem-vindo, Kalell',
            style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
          ),
        ),
      )
          : Container(
        key: ValueKey('Content_$_selectedIndex'),
        color: _bgDark,
        child: _screens[_selectedIndex],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 800;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: _bgDark,
      appBar: _buildAppBar(),
      drawer: isMobile ? Drawer(backgroundColor: _sidebarDark, child: _buildDrawer()) : null,
      body: isMobile
          ? _buildBody()
          : Row(
        children: [
          _buildDrawer(),
          VerticalDivider(thickness: 1, width: 1, color: Colors.white.withOpacity(0.05)),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }
}