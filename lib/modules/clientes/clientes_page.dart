import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:oficina_conectada_front/core/constants/app_colors.dart';
import 'package:oficina_conectada_front/models/cliente_carro_request_model.dart';
import 'package:oficina_conectada_front/models/cliente_model.dart';
import 'package:oficina_conectada_front/modules/clientes/clientes_bloc.dart';
import 'package:oficina_conectada_front/modules/clientes/clientes_event.dart';
import 'package:oficina_conectada_front/modules/clientes/clientes_service.dart';
import 'package:oficina_conectada_front/modules/clientes/clientes_state.dart';
import 'package:oficina_conectada_front/shared/widgets/custom_toast/custom_toast.dart';

class ClientesPage extends StatefulWidget {
  const ClientesPage({super.key});

  @override
  State<ClientesPage> createState() => _ClientesPageState();
}

class _ClientesPageState extends State<ClientesPage> {

// ========= BLOC / INSTÂNCIAS / CONTROLLERS =========

  late ClientesBloc _clientesBloc;
  late ClientesService _clientesService;
  late TextEditingController _nomeController;
  late TextEditingController _telefoneController;
  late TextEditingController _cpfController;
  late TextEditingController _emailController;
  late TextEditingController _enderecoController;
  late TextEditingController _modeloController;
  late TextEditingController _placaController;
  late TextEditingController _anoController;
  late TextEditingController _marcaController;
  late TextEditingController _corController;

// ========= VARIÁVEIS =========

  String _textoBusca = '';
  final _mascaraCpf = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {'#': RegExp(r'[0-9]')},
  );
  final _mascaraTelefone = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {'#': RegExp(r'[0-9]')},
  );

// ========= FUNÇÕES =========

  String _iniciais(String nome) {
    if (nome.isEmpty) return '??';
    final partes = nome.trim().split(' ');
    if (partes.length >= 2) return '${partes.first[0]}${partes.last[0]}'.toUpperCase();
    return partes.first.substring(0, partes.first.length > 1 ? 2 : 1).toUpperCase();
  }

  void _limparFormulario() {
    _nomeController.clear();
    _telefoneController.clear();
    _cpfController.clear();
    _emailController.clear();
    _enderecoController.clear();
    _modeloController.clear();
    _placaController.clear();
    _anoController.clear();
    _marcaController.clear();
    _corController.clear();
  }

  void _abrirModalNovoCliente() {
    _limparFormulario();
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: _construirModalNovoCliente(ctx),
        ),
      ),
    );
  }

  void _enviarFormulario(BuildContext ctx) {
    if (_nomeController.text.isEmpty) {
      CustomToast.show(context, message: 'O nome é obrigatório', type: ToastType.atencao);
      return;
    }

    final temCarro = _placaController.text.isNotEmpty || _modeloController.text.isNotEmpty;

    if (temCarro) {
      final dto = ClienteCarroRequestModel(
        nome: _nomeController.text,
        cpf: _cpfController.text,
        telefone: _telefoneController.text,
        email: _emailController.text,
        placa: _placaController.text,
        modelo: _modeloController.text,
        marca: _marcaController.text,
        ano: _anoController.text,
        cor: _corController.text,
      );
      _clientesBloc.add(CriarClienteComCarro(dto));
    } else {
      final cliente = ClienteModel(
        nome: _nomeController.text,
        cpf: _cpfController.text,
        telefone: _telefoneController.text,
        email: _emailController.text,
      );
      _clientesBloc.add(CriarClienteSimples(cliente));
    }

    Navigator.pop(ctx);
  }

  Future<void> _confirmarDelecao(int id, String nome) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.fundoCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.borda),
        ),
        title: const Text('Excluir Cliente', style: TextStyle(color: Colors.white, fontSize: 16)),
        content: Text(
          'Tem certeza que deseja excluir "$nome"? Esta ação não pode ser desfeita.',
          style: const TextStyle(color: Colors.white54, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.erro,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmado == true) {
      _clientesBloc.add(DeletarCliente(id));
    }
  }

// ========= INIT STATE =========

  @override
  void initState() {
    super.initState();
    _clientesService = ClientesService();
    _clientesBloc = ClientesBloc(_clientesService);
    _nomeController = TextEditingController();
    _telefoneController = TextEditingController();
    _cpfController = TextEditingController();
    _emailController = TextEditingController();
    _enderecoController = TextEditingController();
    _modeloController = TextEditingController();
    _placaController = TextEditingController();
    _anoController = TextEditingController();
    _marcaController = TextEditingController();
    _corController = TextEditingController();
    _clientesBloc.add(CarregarClientes());
  }

// ========= COMPONENTES DA TELA =========

  Widget _construirHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Clientes',
                style: TextStyle(color: AppColors.textoPrincipal, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                'Cadastro e histórico de clientes e veículos',
                style: TextStyle(color: AppColors.textoSecundario, fontSize: 14),
              ),
            ],
          ),
          ElevatedButton.icon(
            onPressed: _abrirModalNovoCliente,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaria,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Novo Cliente', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _construirBusca() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: 350,
        child: TextField(
          onChanged: (v) => setState(() => _textoBusca = v),
          style: const TextStyle(color: AppColors.textoPrincipal, fontSize: 13),
          decoration: InputDecoration(
            hintText: 'Buscar por nome, telefone, veículo, placa...',
            hintStyle: const TextStyle(color: AppColors.textoSecundario),
            prefixIcon: const Icon(Icons.search, color: AppColors.textoSecundario, size: 16),
            filled: true,
            fillColor: AppColors.fundoCard,
            contentPadding: const EdgeInsets.symmetric(vertical: 0),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.borda),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primaria),
            ),
          ),
        ),
      ),
    );
  }

  Widget _construirGrade(List<ClienteModel> clientes) {
    if (clientes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.fundoCard,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.people_outline, color: Colors.white24, size: 40),
            ),
            const SizedBox(height: 16),
            const Text('Nenhum cliente encontrado', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Tente ajustar a busca ou cadastre um novo cliente.', style: TextStyle(color: Colors.white54, fontSize: 12)),
          ],
        ),
      );
    }

    final largura = MediaQuery.of(context).size.width;
    final colunas = largura > 1200 ? 3 : largura > 800 ? 2 : 1;

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: colunas,
        mainAxisExtent: 220,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: clientes.length,
      itemBuilder: (context, index) => _construirCardCliente(clientes[index]),
    );
  }

  Widget _construirCardCliente(ClienteModel cliente) {
    final totalCarros = cliente.carros?.length ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.fundoCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borda),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                      color: AppColors.primaria.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _iniciais(cliente.nome),
                      style: const TextStyle(color: AppColors.primaria, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cliente.nome,
                        style: const TextStyle(color: AppColors.textoPrincipal, fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      const Text('Cliente', style: TextStyle(color: AppColors.textoSecundario, fontSize: 11)),
                    ],
                  ),
                ],
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_horiz, color: AppColors.textoSecundario, size: 20),
                color: AppColors.fundoCard,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: AppColors.borda),
                ),
                onSelected: (value) {
                  if (value == 'excluir') {
                    _confirmarDelecao(cliente.id!, cliente.nome);
                  } else if (value == 'editar' || value == 'perfil') {
                    CustomToast.show(context, message: 'Em breve!', type: ToastType.atencao);
                  }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'perfil',
                    child: Text('Ver Perfil', style: TextStyle(color: Colors.white, fontSize: 13)),
                  ),
                  const PopupMenuItem(
                    value: 'editar',
                    child: Text('Editar', style: TextStyle(color: Colors.white, fontSize: 13)),
                  ),
                  const PopupMenuItem(
                    value: 'excluir',
                    child: Text('Excluir', style: TextStyle(color: Colors.redAccent, fontSize: 13)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _construirInfoCliente(Icons.phone_outlined, cliente.telefone ?? 'Não informado'),
          const SizedBox(height: 6),
          _construirInfoCliente(Icons.email_outlined, cliente.email ?? 'Não informado'),
          const SizedBox(height: 6),
          _construirInfoCliente(Icons.badge_outlined, cliente.cpf ?? 'CPF não informado'),
          const Spacer(),
          Divider(color: AppColors.borda, height: 1),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.directions_car_outlined, color: AppColors.textoSecundario, size: 14),
                  const SizedBox(width: 4),
                  Text('Veículos ($totalCarros)', style: const TextStyle(color: AppColors.textoSecundario, fontSize: 11)),
                ],
              ),
              const Row(
                children: [
                  Icon(Icons.assignment_outlined, color: AppColors.textoSecundario, size: 14),
                  SizedBox(width: 4),
                  Text('0 OS', style: TextStyle(color: AppColors.textoSecundario, fontSize: 11)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: (cliente.carros ?? []).map((carro) {
                return Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.fundoPrincipal.withValues(alpha: 0.5),
                    border: Border.all(color: AppColors.borda),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${carro.modelo} ${carro.ano ?? ''} - ${carro.placa}',
                    style: const TextStyle(color: AppColors.textoSecundario, fontSize: 10),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirInfoCliente(IconData icone, String texto) {
    return Row(
      children: [
        Icon(icone, color: AppColors.textoSecundario, size: 14),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            texto,
            style: const TextStyle(color: AppColors.textoSecundario, fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _construirModalNovoCliente(BuildContext ctx) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.fundoCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borda),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Novo Cliente', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text('Cadastre um novo cliente no sistema.', style: TextStyle(color: Colors.white54, fontSize: 13)),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white54),
                  onPressed: () => Navigator.pop(ctx),
                  splashRadius: 20,
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.white10),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _construirLabel('Nome Completo'),
                  _construirCampo(_nomeController, 'Nome do cliente',
                      capitalizacao: TextCapitalization.words),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          _construirLabel('Telefone'),
                          _construirCampo(_telefoneController, '(00) 00000-0000',
                              teclado: TextInputType.phone, formatadores: [_mascaraTelefone]),
                        ]),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          _construirLabel('E-mail'),
                          _construirCampo(_emailController, 'email@exemplo.com',
                              teclado: TextInputType.emailAddress),
                        ]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          _construirLabel('CPF'),
                          _construirCampo(_cpfController, '000.000.000-00',
                              teclado: TextInputType.number, formatadores: [_mascaraCpf]),
                        ]),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          _construirLabel('Endereço'),
                          _construirCampo(_enderecoController, 'Rua, número, bairro...'),
                        ]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(height: 1, color: Colors.white10),
                  const SizedBox(height: 16),
                  const Text('Veículo (opcional)',
                      style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          _construirLabel('Marca', pequeno: true),
                          _construirCampo(_marcaController, 'Ex: Honda',
                              capitalizacao: TextCapitalization.words),
                        ]),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          _construirLabel('Modelo', pequeno: true),
                          _construirCampo(_modeloController, 'Ex: Civic',
                              capitalizacao: TextCapitalization.words),
                        ]),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          _construirLabel('Placa', pequeno: true),
                          _construirCampo(_placaController, 'ABC-1D23',
                              capitalizacao: TextCapitalization.characters,
                              formatadores: [_UpperCaseFormatter()]),
                        ]),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 1,
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          _construirLabel('Ano', pequeno: true),
                          _construirCampo(_anoController, '2024', teclado: TextInputType.number),
                        ]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1, color: Colors.white10),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                    ),
                  ),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => _enviarFormulario(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaria,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Cadastrar', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirLabel(String label, {bool pequeno = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: TextStyle(
          color: pequeno ? AppColors.textoSecundario : AppColors.textoPrincipal,
          fontSize: pequeno ? 12 : 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _construirCampo(
    TextEditingController controller,
    String hint, {
    TextInputType teclado = TextInputType.text,
    List<TextInputFormatter>? formatadores,
    TextCapitalization capitalizacao = TextCapitalization.none,
  }) {
    return SizedBox(
      height: 40,
      child: TextField(
        controller: controller,
        keyboardType: teclado,
        inputFormatters: formatadores,
        textCapitalization: capitalizacao,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white24),
          filled: true,
          fillColor: AppColors.fundoPrincipal,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: AppColors.borda),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: AppColors.primaria),
          ),
        ),
      ),
    );
  }

// ========= BLOC BUILDER =========

  Widget _blocBuilder() {
    return BlocConsumer<ClientesBloc, ClientesState>(
      bloc: _clientesBloc,
      listener: (context, estado) {
        if (estado is ClientesErro) {
          CustomToast.show(context, message: estado.mensagem, type: ToastType.erro);
        }
        if (estado is ClienteDeletado) {
          CustomToast.show(context, message: 'Cliente excluído com sucesso', type: ToastType.sucesso);
        }
      },
      builder: (context, estado) {
        List<ClienteModel> clientes = [];
        if (estado is ClientesCarregados) {
          clientes = estado.clientes;
        }

        final clientesFiltrados = clientes.where((c) {
          final busca = _textoBusca.toLowerCase();
          return c.nome.toLowerCase().contains(busca) ||
              (c.email ?? '').toLowerCase().contains(busca) ||
              (c.telefone ?? '').contains(busca) ||
              (c.carros?.any((v) =>
                      v.modelo.toLowerCase().contains(busca) ||
                      v.placa.toLowerCase().contains(busca)) ??
                  false);
        }).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _construirHeader(),
            _construirBusca(),
            const SizedBox(height: 16),
            Expanded(
              child: estado is ClientesCarregando && clientes.isEmpty
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primaria))
                  : _construirGrade(clientesFiltrados),
            ),
          ],
        );
      },
    );
  }

// ========= BUILD =========

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fundoPrincipal,
      body: _blocBuilder(),
    );
  }

// ========= DISPOSE =========

  @override
  void dispose() {
    _clientesBloc.close();
    _nomeController.dispose();
    _telefoneController.dispose();
    _cpfController.dispose();
    _emailController.dispose();
    _enderecoController.dispose();
    _modeloController.dispose();
    _placaController.dispose();
    _anoController.dispose();
    _marcaController.dispose();
    _corController.dispose();
    super.dispose();
  }
}

class _UpperCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(text: newValue.text.toUpperCase(), selection: newValue.selection);
  }
}
