import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../components/toast/custom_toast.dart';
import '../model/cliente_carro_request_model.dart';
import '../model/cliente_model.dart';
import 'cliente_bloc.dart';
import 'cliente_event.dart';
import 'cliente_repository.dart';
import 'cliente_state.dart';

class ClientesPage extends StatefulWidget {
  const ClientesPage({super.key});

  @override
  State<ClientesPage> createState() => _ClientesPageState();
}

class _ClientesPageState extends State<ClientesPage> {
  late ClienteBloc _bloc;
  String _searchQuery = '';

  // Controladores do Formulário
  final _nomeController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _cpfController = TextEditingController();
  final _emailController = TextEditingController();
  final _enderecoController = TextEditingController(); // Apenas visual/mock no momento
  final _modeloController = TextEditingController();
  final _placaController = TextEditingController();
  final _anoController = TextEditingController();

  // Cores
  final Color _bgDark = const Color(0xFF09090B);
  final Color _cardDark = const Color(0xFF18181B);
  final Color _borderColor = const Color(0xFF27272A);
  final Color _primaryColor = const Color(0xFF10B981);
  final Color _textForeground = const Color(0xFFFAFAFA);
  final Color _textMuted = const Color(0xFFA1A1AA);

  @override
  void initState() {
    super.initState();
    _bloc = ClienteBloc(ClienteRepository());
    _bloc.add(CarregarClientes());
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _telefoneController.dispose();
    _cpfController.dispose();
    _emailController.dispose();
    _enderecoController.dispose();
    _modeloController.dispose();
    _placaController.dispose();
    _anoController.dispose();
    super.dispose();
  }

  // Pega as iniciais do nome para o Avatar (ex: Tanjiro Kamado -> TK)
  String _getInitials(String name) {
    if (name.isEmpty) return '??';
    List<String> names = name.trim().split(' ');
    if (names.length >= 2) {
      return '${names.first[0]}${names.last[0]}'.toUpperCase();
    }
    return names.first.substring(0, names.first.length > 1 ? 2 : 1).toUpperCase();
  }

  void _mostrarModalNovoCliente() {
    _nomeController.clear();
    _telefoneController.clear();
    _cpfController.clear();
    _emailController.clear();
    _enderecoController.clear();
    _modeloController.clear();
    _placaController.clear();
    _anoController.clear();

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: _cardDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: _borderColor),
          ),
          child: Container(
            width: 500,
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Novo Cliente',
                            style: TextStyle(
                              color: _textForeground,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Cadastre um novo cliente no sistema.',
                            style: TextStyle(color: _textMuted.withOpacity(0.8), fontSize: 14),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: _textMuted),
                        onPressed: () => Navigator.pop(context),
                        splashRadius: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // DADOS PESSOAIS
                  _buildInputLabel('Nome Completo'),
                  _buildTextField(_nomeController, 'Nome do cliente'),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInputLabel('Telefone'),
                            _buildTextField(_telefoneController, '(00) 00000-0000'),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInputLabel('E-mail'),
                            _buildTextField(_emailController, 'email@exemplo.com'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInputLabel('CPF'),
                            _buildTextField(_cpfController, '000.000.000-00'),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInputLabel('Endereço'),
                            _buildTextField(_enderecoController, 'Rua, número, bairro...'),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  Divider(color: _borderColor),
                  const SizedBox(height: 16),

                  Text(
                    'Veículo (opcional)',
                    style: TextStyle(
                      color: _textForeground,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInputLabel('Modelo', isSmall: true),
                            _buildTextField(_modeloController, 'Ex: Civic'),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInputLabel('Placa', isSmall: true),
                            _buildTextField(_placaController, 'ABC-1D23'),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInputLabel('Ano', isSmall: true),
                            _buildTextField(_anoController, '2024'),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          foregroundColor: _textForeground,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(color: _borderColor),
                          ),
                        ),
                        child: const Text('Cancelar'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: _enviarFormulario,
                        child: const Text(
                          'Cadastrar',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _enviarFormulario() {
    if (_nomeController.text.isEmpty) {
      CustomToast.show(context, message: 'O nome é obrigatório', type: ToastType.error);
      return;
    }

    final temCarro = _placaController.text.isNotEmpty || _modeloController.text.isNotEmpty;

    if (temCarro) {
      // Dispara endpoint /completo
      final dto = ClienteCarroRequestModel(
        nome: _nomeController.text,
        cpf: _cpfController.text,
        telefone: _telefoneController.text,
        email: _emailController.text,
        placa: _placaController.text,
        modelo: _modeloController.text,
        ano: _anoController.text,
        marca: '',
        cor: '',
      );
      _bloc.add(CriarClienteComCarro(dto));
    } else {
      // Dispara endpoint cliente simples
      final cliente = ClienteModel(
        nome: _nomeController.text,
        cpf: _cpfController.text,
        telefone: _telefoneController.text,
        email: _emailController.text,
      );
      _bloc.add(CriarClienteSimples(cliente));
    }

    Navigator.pop(context);
  }

  Widget _buildInputLabel(String label, {bool isSmall = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: TextStyle(
          color: isSmall ? _textMuted : _textForeground,
          fontSize: isSmall ? 12 : 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint) {
    return SizedBox(
      height: 40,
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white24),
          filled: true,
          fillColor: _bgDark,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: _borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: _primaryColor),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDark,
      body: BlocConsumer<ClienteBloc, ClienteState>(
        bloc: _bloc,
        listener: (context, state) {
          if (state is ClienteActionSuccess) {
            CustomToast.show(context, message: state.mensagem, type: ToastType.success);
          } else if (state is ClienteError) {
            CustomToast.show(context, message: state.mensagem, type: ToastType.error);
          }
        },
        builder: (context, state) {
          List<ClienteModel> clientes = [];
          if (state is ClienteLoaded) {
            clientes = state.clientes;
          }

          // Filtro de busca
          final filtered = clientes.where((c) {
            final query = _searchQuery.toLowerCase();
            final matchNome = c.nome.toLowerCase().contains(query);
            final matchEmail = (c.email ?? '').toLowerCase().contains(query);
            final matchTelefone = (c.telefone ?? '').contains(query);
            final matchCarro =
                c.carros?.any(
                  (v) =>
                      v.modelo.toLowerCase().contains(query) ||
                      v.placa.toLowerCase().contains(query),
                ) ??
                false;

            return matchNome || matchEmail || matchTelefone || matchCarro;
          }).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SizedBox(
                  width: 350,
                  height: 40,
                  child: TextField(
                    onChanged: (v) => setState(() => _searchQuery = v),
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Buscar por nome, telefone, veículo, placa...',
                      hintStyle: const TextStyle(color: Colors.white24),
                      prefixIcon: const Icon(Icons.search, color: Colors.white24, size: 16),
                      filled: true,
                      fillColor: _cardDark,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide(color: _borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide(color: _primaryColor),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Expanded(
                child: state is ClienteLoading && clientes.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : _buildGrid(filtered),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Clientes',
                style: TextStyle(color: _textForeground, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Cadastro e histórico de clientes e veículos',
                style: TextStyle(color: _textMuted.withOpacity(0.8), fontSize: 14),
              ),
            ],
          ),
          ElevatedButton.icon(
            onPressed: _mostrarModalNovoCliente,
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Novo Cliente', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(List<ClienteModel> clientes) {
    if (clientes.isEmpty) {
      return Center(
        child: Text('Nenhum cliente encontrado.', style: TextStyle(color: _textMuted)),
      );
    }

    int crossAxisCount = 1;
    final width = MediaQuery.of(context).size.width;
    if (width > 1200)
      crossAxisCount = 3;
    else if (width > 800)
      crossAxisCount = 2;

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisExtent: 220,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: clientes.length,
      itemBuilder: (context, index) {
        final client = clientes[index];
        final totalVeiculos = client.carros?.length ?? 0;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _cardDark,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //  Avatar e Nome
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _primaryColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _getInitials(client.nome),
                          style: TextStyle(
                            color: _primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            client.nome,
                            style: TextStyle(
                              color: _textForeground,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'Última visita: Hoje',
                            style: TextStyle(color: _textMuted, fontSize: 11),
                          ),
                        ],
                      ),
                    ],
                  ),
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_horiz, color: _textMuted, size: 20),
                    color: _cardDark,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: _borderColor),
                    ),
                    onSelected: (value) {
                      if (value == 'excluir') _bloc.add(DeletarCliente(client.id!));
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'perfil',
                        child: Text(
                          'Ver Perfil',
                          style: TextStyle(color: Colors.white, fontSize: 13),
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'editar',
                        child: Text('Editar', style: TextStyle(color: Colors.white, fontSize: 13)),
                      ),
                      const PopupMenuItem(
                        value: 'os',
                        child: Text('Nova OS', style: TextStyle(color: Colors.white, fontSize: 13)),
                      ),
                      const PopupMenuItem(
                        value: 'excluir',
                        child: Text(
                          'Excluir',
                          style: TextStyle(color: Colors.redAccent, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Icon(Icons.phone_outlined, color: _textMuted, size: 14),
                  const SizedBox(width: 8),
                  Text(
                    client.telefone ?? 'Não informado',
                    style: TextStyle(color: _textMuted, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.email_outlined, color: _textMuted, size: 14),
                  const SizedBox(width: 8),
                  Text(
                    client.email ?? 'Não informado',
                    style: TextStyle(color: _textMuted, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.pin_drop_outlined, color: _textMuted, size: 14),
                  const SizedBox(width: 8),
                  Text(
                    client.cpf ?? 'CPF não informado',
                    style: TextStyle(color: _textMuted, fontSize: 12),
                  ),
                ],
              ),

              const Spacer(),
              Divider(color: _borderColor, height: 1),
              const Spacer(),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.directions_car_outlined, color: _textMuted, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        'Veículos ($totalVeiculos)',
                        style: TextStyle(color: _textMuted, fontSize: 11),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.assignment_outlined, color: _textMuted, size: 14),
                      const SizedBox(width: 4),
                      Text('0 OS', style: TextStyle(color: _textMuted, fontSize: 11)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: (client.carros ?? []).map((carro) {
                    return Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _bgDark.withOpacity(0.5),
                        border: Border.all(color: _borderColor),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${carro.modelo} ${carro.ano ?? ''} - ${carro.placa}',
                        style: TextStyle(color: _textMuted, fontSize: 10),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
