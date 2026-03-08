import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../components/toast/custom_toast.dart';
import '../model/carro_model.dart';
import 'carro_cadastro_bloc.dart';
import 'carro_cadastro_event.dart';
import 'carro_cadastro_repository.dart';
import 'carro_cadastro_state.dart';

class VeiculosPage extends StatefulWidget {
  const VeiculosPage({super.key});

  @override
  State<VeiculosPage> createState() => _VeiculosPageState();
}

class _VeiculosPageState extends State<VeiculosPage> {
  late CarroBloc _bloc;

  String _searchQuery = '';
  String _statusFilter = 'all';

  final _marcaController = TextEditingController();
  final _modeloController = TextEditingController();
  final _placaController = TextEditingController();
  final _anoController = TextEditingController();
  final _corController = TextEditingController();
  int? _clienteSelecionadoId;

  final Color _bgDark = const Color(0xFF09090B);
  final Color _cardDark = const Color(0xFF18181B);
  final Color _borderColor = const Color(0xFF27272A);
  final Color _primaryColor = const Color(0xFF10B981);
  final Color _infoColor = const Color(0xFF3B82F6);
  final Color _warningColor = const Color(0xFFF59E0B);
  final Color _successColor = const Color(0xFF22C55E);
  final Color _textForeground = const Color(0xFFFAFAFA);
  final Color _textMuted = const Color(0xFFA1A1AA);

  @override
  void initState() {
    super.initState();
    _bloc = CarroBloc(CarroRepository());
    _bloc.add(CarregarCarros());
  }

  @override
  void dispose() {
    _marcaController.dispose();
    _modeloController.dispose();
    _placaController.dispose();
    _anoController.dispose();
    _corController.dispose();
    super.dispose();
  }

  Map<String, dynamic> _mapStatusUi(String? statusBackend) {
    if (statusBackend == null || statusBackend == 'CONCLUIDA' || statusBackend == 'ENTREGUE') {
      return {'key': 'disponivel', 'label': 'Disponível', 'color': _successColor};
    }
    if (statusBackend.contains('AGUARDANDO')) {
      return {'key': 'aguardando', 'label': 'Aguardando', 'color': _warningColor};
    }
    return {'key': 'em_servico', 'label': 'Em Serviço', 'color': _infoColor};
  }

  void _mostrarModalNovoVeiculo() {
    _marcaController.clear();
    _modeloController.clear();
    _placaController.clear();
    _anoController.clear();
    _corController.clear();
    _clienteSelecionadoId = null;

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
                      Row(
                        children: [
                          Icon(Icons.directions_car, color: _primaryColor, size: 24),
                          const SizedBox(width: 10),
                           Text(
                            'Cadastrar Veículo',
                            style: TextStyle(
                              color: _textForeground,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
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
                  const SizedBox(height: 8),
                  Text(
                    'Preencha as informações do veículo.',
                    style: TextStyle(color: _textMuted, fontSize: 14),
                  ),
                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInputLabel('Marca'),
                            _buildTextField(_marcaController, 'Ex: Honda'),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInputLabel('Modelo'),
                            _buildTextField(_modeloController, 'Ex: Civic'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInputLabel('Placa'),
                            _buildTextField(_placaController, 'ABC-1D23'),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInputLabel('Ano'),
                            _buildTextField(_anoController, '2024'),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInputLabel('Cor'),
                            _buildTextField(_corController, 'Prata'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                   Divider(color: _borderColor),
                  const SizedBox(height: 16),

                  _buildInputLabel('Proprietário (Cliente)'),
                  // TODO: Aqui vou colocar futuramente bloc para pegar cliente
                  DropdownButtonFormField<int>(
                    dropdownColor: _bgDark,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: _bgDark,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide(color: _borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide(color: _primaryColor),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: 1, child: Text('Carlos Silva')),
                      DropdownMenuItem(value: 2, child: Text('Ana Oliveira')),
                    ],
                    onChanged: (val) => _clienteSelecionadoId = val,
                    hint: const Text('Selecionar cliente', style: TextStyle(color: Colors.white24)),
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
                        ),
                        child: const Text('Cancelar'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () {
                          if (_placaController.text.isEmpty || _clienteSelecionadoId == null) {
                            CustomToast.show(
                              context,
                              message: 'Placa e Proprietário são obrigatórios',
                              type: ToastType.error,
                            );
                            return;
                          }
                          final novoCarro = CarroModel(
                            placa: _placaController.text,
                            modelo: _modeloController.text,
                            marca: _marcaController.text,
                            ano: int.tryParse(_anoController.text),
                            cor: _corController.text,
                            clienteId: _clienteSelecionadoId,
                          );
                          _bloc.add(CriarCarro(novoCarro));
                          Navigator.pop(context);
                        },
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

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: TextStyle(color: _textForeground, fontSize: 13, fontWeight: FontWeight.w500),
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
      body: BlocConsumer<CarroBloc, CarroState>(
        bloc: _bloc,
        listener: (context, state) {
          if (state is CarroActionSuccess) {
            CustomToast.show(context, message: state.mensagem, type: ToastType.success);
          } else if (state is CarroError) {
            CustomToast.show(context, message: state.mensagem, type: ToastType.error);
          }
        },
        builder: (context, state) {
          List<CarroStatusModel> frota = [];
          if (state is CarroLoaded) frota = state.carrosComStatus;

          // Contadores
          int countEmServico = 0;
          int countAguardando = 0;
          int countDisponivel = 0;
          for (var item in frota) {
            final ui = _mapStatusUi(item.status);
            if (ui['key'] == 'em_servico')
              countEmServico++;
            else if (ui['key'] == 'aguardando')
              countAguardando++;
            else
              countDisponivel++;
          }

          // Filtros
          final filtered = frota.where((item) {
            final query = _searchQuery.toLowerCase();
            final c = item.carro;
            final matchText =
                c.placa.toLowerCase().contains(query) ||
                c.modelo.toLowerCase().contains(query) ||
                (c.marca ?? '').toLowerCase().contains(query) ||
                (c.nomeCliente ?? '').toLowerCase().contains(query);

            final matchStatus =
                _statusFilter == 'all' || _mapStatusUi(item.status)['key'] == _statusFilter;
            return matchText && matchStatus;
          }).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Veículos',
                          style: TextStyle(
                            color: _textForeground,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Gerenciamento de veículos cadastrados na oficina',
                          style: TextStyle(color: _textMuted, fontSize: 14),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: _mostrarModalNovoVeiculo,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text(
                        'Novo Veículo',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),

              // KPI Cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(child: _buildKpiCard('Em Serviço', countEmServico, _infoColor)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildKpiCard('Aguardando', countAguardando, _warningColor)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildKpiCard('Disponível', countDisponivel, _successColor)),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Barra de Ferramentas (Filtros e Busca)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        _buildFilterButton('Todos', 'all', frota.length),
                        const SizedBox(width: 8),
                        _buildFilterButton('Em Serviço', 'em_servico', countEmServico),
                        const SizedBox(width: 8),
                        _buildFilterButton('Aguardando', 'aguardando', countAguardando),
                        const SizedBox(width: 8),
                        _buildFilterButton('Disponível', 'disponivel', countDisponivel),
                      ],
                    ),
                    SizedBox(
                      width: 300,
                      height: 40,
                      child: TextField(
                        onChanged: (v) => setState(() => _searchQuery = v),
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Buscar por modelo, placa, proprietário...',
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
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Tabela
              Expanded(
                child: state is CarroLoading && frota.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : _buildTable(filtered),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildKpiCard(String title, int count, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.directions_car, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                count.toString(),
                style: TextStyle(color: _textForeground, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(title, style: TextStyle(color: _textMuted, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String label, String key, int count) {
    final isSelected = _statusFilter == key;
    return InkWell(
      onTap: () => setState(() => _statusFilter = key),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? _primaryColor : _cardDark,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: isSelected ? _primaryColor : _borderColor),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : _textMuted,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withOpacity(0.2) : _bgDark,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  color: isSelected ? Colors.white : _textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //tabela generica apenas para refatoraçõa
  //futuramente irei coloca table componente

  Widget _buildTable(List<CarroStatusModel> frota) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Cabeçalho da Tabela
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: _borderColor)),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'Veículo',
                    style: TextStyle(
                        color: _textMuted,
                        fontSize: 13,
                        fontWeight: FontWeight.w600
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Placa',
                    style: TextStyle(
                        color: _textMuted,
                        fontSize: 13,
                        fontWeight: FontWeight.w600
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'Ano',
                    style: TextStyle(
                        color: _textMuted,
                        fontSize: 13,
                        fontWeight: FontWeight.w600
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'Cor',
                    style: TextStyle(
                        color: _textMuted,
                        fontSize: 13,
                        fontWeight: FontWeight.w600
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'Proprietário',
                    style: TextStyle(
                        color: _textMuted,
                        fontSize: 13,
                        fontWeight: FontWeight.w600
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Status',
                    style: TextStyle(
                        color: _textMuted,
                        fontSize: 13,
                        fontWeight: FontWeight.w600
                    ),
                  ),
                ),
                const SizedBox(width: 40),
              ],
            ),
          ),

          // Corpo da Tabela
          Expanded(
            child: frota.isEmpty
                ? Center(
                    child: Text('Nenhum veículo encontrado.', style: TextStyle(color: _textMuted)),
                  )
                : ListView.separated(
                    itemCount: frota.length,
                    separatorBuilder: (_, __) => Divider(height: 1, color: _borderColor),
                    itemBuilder: (context, index) {
                      final item = frota[index];
                      final c = item.carro;
                      final ui = _mapStatusUi(item.status);

                      return InkWell(
                        onTap: () {}, // Vai pra página de detalhes futuramente quando eu implantar
                        hoverColor: Colors.white.withOpacity(0.02),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              // Veículo
                              Expanded(
                                flex: 3,
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: _bgDark,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Icon(
                                        Icons.directions_car_outlined,
                                        color: _primaryColor,
                                        size: 16,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        '${c.marca ?? ''} ${c.modelo}'.trim(),
                                        style: TextStyle(
                                          color: _textForeground,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Placa
                              Expanded(
                                flex: 2,
                                child: Text(
                                  c.placa,
                                  style: TextStyle(
                                    color: _primaryColor,
                                    fontSize: 13,
                                    fontFamily: 'monospace',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              // Ano
                              Expanded(
                                flex: 1,
                                child: Text(
                                  c.ano?.toString() ?? '-',
                                  style: TextStyle(color: _textMuted, fontSize: 13),
                                ),
                              ),
                              // Cor
                              Expanded(
                                flex: 1,
                                child: Text(
                                  c.cor ?? '-',
                                  style: TextStyle(color: _textMuted, fontSize: 13),
                                ),
                              ),
                              // Proprietário
                              Expanded(
                                flex: 3,
                                child: Row(
                                  children: [
                                    Icon(Icons.person_outline, color: _textMuted, size: 14),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        c.nomeCliente ?? 'Sem Dono',
                                        style: TextStyle(color: _textForeground, fontSize: 13),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Status
                              Expanded(
                                flex: 2,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: (ui['color'] as Color).withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: (ui['color'] as Color).withOpacity(0.3),
                                      ),
                                    ),
                                    child: Text(
                                      ui['label'],
                                      style: TextStyle(
                                        color: ui['color'],
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // Ações
                              SizedBox(
                                width: 40,
                                child: PopupMenuButton<String>(
                                  icon: Icon(Icons.more_horiz, color: _textMuted, size: 20),
                                  color: _cardDark,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    side: BorderSide(color: _borderColor),
                                  ),
                                  onSelected: (val) {
                                    if (val == 'excluir') _bloc.add(DeletarCarro(c.id!));
                                  },
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'historico',
                                      child: Text(
                                        'Ver Histórico',
                                        style: TextStyle(color: Colors.white, fontSize: 13),
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'editar',
                                      child: Text(
                                        'Editar',
                                        style: TextStyle(color: Colors.white, fontSize: 13),
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'os',
                                      child: Text(
                                        'Nova OS',
                                        style: TextStyle(color: Colors.white, fontSize: 13),
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'excluir',
                                      child: Text(
                                        'Remover',
                                        style: TextStyle(color: Colors.redAccent, fontSize: 13),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
