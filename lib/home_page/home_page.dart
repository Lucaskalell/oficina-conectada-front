import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../estoque/estoque_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String _currentTitle = 'DashBoard';

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Widget> _screens = [
    // 0: Dashboard
    const Center(
      child: Text('Página: Dashboard (Kanban)', style: TextStyle(fontSize: 24, color: Colors.grey)),
    ),
    // 1: Clientes
    const Center(
      child: Text('Página: Clientes', style: TextStyle(fontSize: 24, color: Colors.grey)),
    ),

    const EstoquePage(),

    // 3: Chat
    const Center(
      child: Text('Página: Chat', style: TextStyle(fontSize: 24, color: Colors.grey)),
    ),
    // 4: Configuração
    const Center(
      child: Text('Página: Configuração', style: TextStyle(fontSize: 24, color: Colors.grey)),
    ),
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

  Future<void> _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  void initState() {
    super.initState();
  }

  Widget _buildProfileAvatar() {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'perfil') {
          print('Abrir tela de Perfil');
        }
        if (value == 'sair') {
          _handleLogout();
        }
      },
      tooltip: "Opções de Conta",
      child: CircleAvatar(
        radius: 18,
        backgroundImage: AssetImage('assets/images/tomioka.png'),
        backgroundColor: Colors.grey.shade700,
      ),
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(value: 'perfil', child: Text('Ver Perfil')),
        const PopupMenuItem<String>(
          value: 'sair',
          child: Text('Sair', style: TextStyle(color: Colors.redAccent)),
        ),
      ],
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(_currentTitle),
      backgroundColor: Colors.grey.shade900,
      elevation: 1,
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none_outlined),
          tooltip: 'Notificações',
          onPressed: () {
            /* TODO: Abrir painel de notificações */
          },
        ),

        ElevatedButton.icon(
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Nova Ordem de Serviço'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () {
            /* TODO: Abrir modal de "Nova OS" */
          },
        ),

        const SizedBox(width: 16),
        _buildProfileAvatar(),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildDrawer() {
    return Container(
      width: 250,
      color: const Color(0xff252526),
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                UserAccountsDrawerHeader(
                  accountName: const Text(
                    'Oficina do Tomioka',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  accountEmail: const Text('lucas@email.com'), // TODO: Puxar o obejeto usuario
                  currentAccountPicture: CircleAvatar(
                    backgroundImage: AssetImage('assets/images/tomioka.png'),
                    backgroundColor: Colors.grey.shade300,
                  ),
                  decoration: BoxDecoration(color: Colors.grey.shade800),
                ),

                const SizedBox(height: 10),

                // --- Itens do Menu ---
                ListTile(
                  leading: Icon(
                    Icons.dashboard_outlined,
                    color: _selectedIndex == 0 ? Colors.white : Colors.grey.shade400,
                  ),
                  title: Text(
                    'Dashboard',
                    style: TextStyle(color: _selectedIndex == 0 ? Colors.white : Colors.grey.shade300),
                  ),
                  tileColor: _selectedIndex == 0 ? Colors.blueAccent.withOpacity(0.2) : null,
                  onTap: () => _onScreenSelected(0, 'Dashboard'),
                ),
                ListTile(
                  leading: Icon(Icons.people_outline, color: _selectedIndex == 1 ? Colors.white : Colors.grey.shade400),
                  title: Text(
                    'Clientes',
                    style: TextStyle(color: _selectedIndex == 1 ? Colors.white : Colors.grey.shade300),
                  ),
                  tileColor: _selectedIndex == 1 ? Colors.blueAccent.withOpacity(0.2) : null,
                  onTap: () => _onScreenSelected(1, 'Clientes'),
                ),
                ListTile(
                  leading: Icon(
                    Icons.inventory_2_outlined,
                    color: _selectedIndex == 2 ? Colors.white : Colors.grey.shade400,
                  ),
                  title: Text(
                    'Estoque',
                    style: TextStyle(color: _selectedIndex == 2 ? Colors.white : Colors.grey.shade300),
                  ),
                  tileColor: _selectedIndex == 2 ? Colors.blueAccent.withOpacity(0.2) : null,
                  onTap: () => _onScreenSelected(2, 'Estoque'),
                ),
                ListTile(
                  leading: Icon(
                    Icons.chat_bubble_outline,
                    color: _selectedIndex == 3 ? Colors.white : Colors.grey.shade400,
                  ),
                  title: Text(
                    'Chat',
                    style: TextStyle(color: _selectedIndex == 3 ? Colors.white : Colors.grey.shade300),
                  ),
                  tileColor: _selectedIndex == 3 ? Colors.blueAccent.withOpacity(0.2) : null,
                  onTap: () => _onScreenSelected(3, 'Chat'),
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Divider(thickness: 0.5, color: Colors.grey),
                ),

                ListTile(
                  leading: Icon(
                    Icons.settings_outlined,
                    color: _selectedIndex == 4 ? Colors.white : Colors.grey.shade400,
                  ),
                  title: Text(
                    'Configuração',
                    style: TextStyle(color: _selectedIndex == 4 ? Colors.white : Colors.grey.shade300),
                  ),
                  tileColor: _selectedIndex == 4 ? Colors.blueAccent.withOpacity(0.2) : null,
                  onTap: () => _onScreenSelected(4, 'Configuração'),
                ),
              ],
            ),
          ),

          SafeArea(
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text('Sair', style: TextStyle(color: Colors.redAccent, fontSize: 16)),
              onTap: _handleLogout,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(image: AssetImage('assets/images/testehome.png'), fit: BoxFit.cover),
      ),
      child: _screens[_selectedIndex],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 800;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFF121212),
      appBar: _buildAppBar(),
      drawer: isMobile ? Drawer(child: _buildDrawer()) : null,
      body: isMobile
          ? _buildBody()
          : Row(
              children: [
                _buildDrawer(),
                const VerticalDivider(thickness: 1, width: 1, color: Colors.black),
                Expanded(child: _buildBody()),
              ],
            ),
    );
  }
}
