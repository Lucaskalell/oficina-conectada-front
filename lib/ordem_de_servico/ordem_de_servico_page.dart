import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oficina_conectada_front/model/add_ordem_de_servico/ordem_de_servico_model.dart';
import 'package:oficina_conectada_front/ordem_de_servico/ordem_de_servico_event.dart';
import 'package:oficina_conectada_front/ordem_de_servico/ordem_de_servico_state.dart';
import '../components/toast/custom_toast.dart';
import 'adicionar_ordem_de_servico/adicionar_ordem_page.dart';
import 'ordem_de_servico_bloc.dart';
import 'ordem_de_servico_repository.dart';

class OrdemServicoPage extends StatefulWidget {
  const OrdemServicoPage({super.key});

  @override
  State<OrdemServicoPage> createState() => _OrdemServicoPageState();
}

class _OrdemServicoPageState extends State<OrdemServicoPage> {
  late OrdemDeServicoBloc _ordemDeServicoBloc;
  String _searchQuery = '';
  String _statusFilter = 'Todos';

  // Cores Padrão do app
  final Color _bgDark = const Color(0xFF09090B);
  final Color _cardDark = const Color(0xFF18181B);
  final Color _borderColor = Colors.white.withOpacity(0.1);
  final Color _primaryColor = const Color(0xFF10B981);

  @override
  void initState() {
    super.initState();
    _ordemDeServicoBloc = OrdemDeServicoBloc(OrdemDeServicoRepository());
    _loadData();
  }

  void _loadData() {
    _ordemDeServicoBloc.add(CarregarListaDeOrdemDeServico());
  }

  @override
  void dispose() {
    _ordemDeServicoBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDark,
      body: BlocConsumer<OrdemDeServicoBloc, OrdemDeServicoState>(
        bloc: _ordemDeServicoBloc,
        listener: _blocListener,
        builder: (context, state) {
          List<OrdemDeServicoModel> ordens = [];
          if (state is OrdemDeServicoListSuccessState) {
            ordens = state.ordensDeServico;
          }

          // Filtro local baseado na busca e na aba de status
          final filteredOrdens = ordens.where((ordem) {
            final matchSearch =
                (ordem.cliente?.toLowerCase() ?? '').contains(_searchQuery.toLowerCase()) ||
                    (ordem.carro?.toLowerCase() ?? '').contains(_searchQuery.toLowerCase()) ||
                    (ordem.placa?.toLowerCase() ?? '').contains(_searchQuery.toLowerCase());

            final matchStatus = _statusFilter == 'Todos' || ordem.status.name == _statusFilter;

            return matchSearch && matchStatus;
          }).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              _buildFilters(ordens), // Passando as ordens totais para contar as badges
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: _cardDark,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _borderColor),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: state is OrdemDeServicoLoadingState
                          ? const Center(child: CircularProgressIndicator())
                          : state is OrdemDeServicoErrorState
                          ? _buildErrorState()
                          : _buildTable(filteredOrdens),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // COMPONENTES PRINCIPAIS DA TELA


  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Ordens de Serviço',
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                'Gerencie todas as ordens de serviço da oficina',
                style: TextStyle(color: Colors.white54, fontSize: 14),
              ),
            ],
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CriarOrdemDeServicoPage()),
              ).then((_) => _loadData()); // Recarrega ao voltar
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Nova OS', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(List<OrdemDeServicoModel> todasOrdens) {
    final statusCounts = {
      'Todos': todasOrdens.length,
      'EM_ANDAMENTO': todasOrdens.where((o) => o.status.name == 'EM_ANDAMENTO').length,
      'AGUARDANDO_PECA': todasOrdens.where((o) => o.status.name == 'AGUARDANDO_PECA').length,
      'FINALIZADO': todasOrdens.where((o) => o.status.name == 'FINALIZADO').length,
      'CANCELADO': todasOrdens.where((o) => o.status.name == 'CANCELADO').length,
    };

    final tabs = [
      {'key': 'Todos', 'label': 'Todas'},
      {'key': 'EM_ANDAMENTO', 'label': 'Em Andamento'},
      {'key': 'AGUARDANDO_PECA', 'label': 'Aguard. Peça'},
      {'key': 'FINALIZADO', 'label': 'Concluídas'},
      {'key': 'CANCELADO', 'label': 'Canceladas'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Abas de Status
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tabs.map((tab) {
              final isSelected = _statusFilter == tab['key'];
              return InkWell(
                onTap: () => setState(() => _statusFilter = tab['key']!),
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? _primaryColor : _cardDark,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: isSelected ? _primaryColor : _borderColor),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        tab['label']!,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white70,
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white.withOpacity(0.2) : Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${statusCounts[tab['key']]}',
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.white54,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          // Barra de Busca
          SizedBox(
            width: 350,
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Buscar por cliente, veículo, placa...',
                hintStyle: const TextStyle(color: Colors.white24),
                prefixIcon: const Icon(Icons.search, color: Colors.white24, size: 18),
                filled: true,
                fillColor: _cardDark,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: _borderColor)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: _primaryColor)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTable(List<OrdemDeServicoModel> ordens) {
    if (ordens.isEmpty) {
      return const Center(
        child: Text('Nenhuma ordem de serviço encontrada.', style: TextStyle(color: Colors.white54)),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width - 48), // Ocupar pelo menos a tela inteira
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(_bgDark.withOpacity(0.5)),
          dataRowMinHeight: 60,
          dataRowMaxHeight: 60,
          horizontalMargin: 24,
          columnSpacing: 24,
          dividerThickness: 1,
          border: TableBorder(horizontalInside: BorderSide(color: _borderColor)),
          columns: const [
            DataColumn(label: Text('OS', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Cliente', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Veículo', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Serviço', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Status', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Valor', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold))),
            DataColumn(label: Text('', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold))), // Ações
          ],
          rows: ordens.map((ordem) {
            final configStatus = _getStatusConfig(ordem.status.name);

            return DataRow(
              cells: [
                DataCell(Text('OS-${ordem.id ?? "000"}', style: TextStyle(color: _primaryColor, fontFamily: 'monospace', fontSize: 12))),
                DataCell(Text(ordem.cliente ?? 'N/A', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500))),
                DataCell(Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ordem.carro ?? 'N/A', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                    Text(ordem.placa ?? '---', style: const TextStyle(color: Colors.white38, fontSize: 11)),
                  ],
                )),
                DataCell(Text(ordem.descricaoServico ?? 'N/A', style: const TextStyle(color: Colors.white, fontSize: 13))),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: configStatus.color.withOpacity(0.15),
                      border: Border.all(color: configStatus.color.withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(configStatus.icon, color: configStatus.color, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          configStatus.label,
                          style: TextStyle(color: configStatus.color, fontSize: 11, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),
                DataCell(Text('R\$ ${ordem.valorTotal?.toStringAsFixed(2) ?? "0.00"}', style: const TextStyle(color: Colors.white, fontFamily: 'monospace'))),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: Colors.white54, size: 18),
                        onPressed: () => _ordemDeServicoBloc.add(EditarOrdemById(ordem)),
                        splashRadius: 20,
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                        onPressed: () => _ordemDeServicoBloc.add(DeletarOrdemDeServico(ordem.id!)),
                        splashRadius: 20,
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
          SizedBox(height: 16),
          Text('Não foi possível carregar as ordens de serviço.', style: TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }


  // auxiliares pr amante cc(codigo limpo)


  void _blocListener(BuildContext context, OrdemDeServicoState state) {
    if (state is OrdemDeServicoErrorState) {
      CustomToast.show(context, message: state.message, type: ToastType.error);
    }

    if (state is OrdemDeServicoDelatadaComSucesso) {
      CustomToast.show(context, message: 'Ordem de serviço deletada com sucesso', type: ToastType.success);
      _loadData();
    }
  }

  _StatusConfig _getStatusConfig(String status) {
    switch (status) {
      case 'EM_ANDAMENTO':
        return _StatusConfig('Em Andamento', Colors.blue, Icons.access_time);
      case 'AGUARDANDO_PECA':
        return _StatusConfig('Aguard. Peça', Colors.orange, Icons.pause_circle_outline);
      case 'FINALIZADO':
        return _StatusConfig('Concluída', _primaryColor, Icons.check_circle_outline);
      case 'CANCELADO':
        return _StatusConfig('Cancelada', Colors.red, Icons.cancel_outlined);
      default:
        return _StatusConfig(status, Colors.grey, Icons.help_outline);
    }
  }
}

class _StatusConfig {
  final String label;
  final Color color;
  final IconData icon;

  _StatusConfig(this.label, this.color, this.icon);
}