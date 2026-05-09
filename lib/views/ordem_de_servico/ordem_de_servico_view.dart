import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oficina_conectada_front/constants/colors.dart';
import 'package:oficina_conectada_front/models/ordem_de_servico_model.dart';
import 'package:oficina_conectada_front/controllers/ordem_de_servico/ordem_de_servico_event.dart';
import 'package:oficina_conectada_front/controllers/ordem_de_servico/ordem_de_servico_state.dart';
import 'package:oficina_conectada_front/widgets/table_all/table_all.dart';
import 'package:oficina_conectada_front/widgets/toast/custom_toast.dart';
import 'package:oficina_conectada_front/models/enums/status_servico.dart';
import 'package:oficina_conectada_front/views/ordem_de_servico/adicionar_ordem_view.dart';
import 'package:oficina_conectada_front/controllers/ordem_de_servico/ordem_de_servico_controller.dart';
import 'package:oficina_conectada_front/services/ordem_de_servico_service.dart';

class OrdemServicoView extends StatefulWidget {
  const OrdemServicoView({super.key});

  @override
  State<OrdemServicoView> createState() => _OrdemServicoViewState();
}

class _OrdemServicoViewState extends State<OrdemServicoView> {
  late OrdemDeServicoController _controller;
  String _searchQuery = '';
  StatusOrdemDeServico? _statusFilter;

  @override
  void initState() {
    super.initState();
    _controller = OrdemDeServicoController(OrdemDeServicoService());
    _loadData();
  }

  void _loadData() {
    _controller.add(CarregarListaDeOrdemDeServico());
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsApp.bgDark,
      body: BlocConsumer<OrdemDeServicoController, OrdemDeServicoState>(
        bloc: _controller,
        listener: _blocListener,
        builder: (context, state) {
          List<OrdemDeServicoModel> ordens = [];
          if (state is OrdemDeServicoListSuccessState) {
            ordens = state.ordensDeServico;
          }

          final filteredOrdens =
              ordens.where((ordem) {
                final matchSearch =
                    (ordem.cliente?.toLowerCase() ?? '').contains(
                      _searchQuery.toLowerCase(),
                    ) ||
                    (ordem.carro?.toLowerCase() ?? '').contains(
                      _searchQuery.toLowerCase(),
                    ) ||
                    (ordem.placa?.toLowerCase() ?? '').contains(
                      _searchQuery.toLowerCase(),
                    );

                final matchStatus =
                    _statusFilter == null || ordem.status == _statusFilter;

                return matchSearch && matchStatus;
              }).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              _buildFilters(ordens),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: ColorsApp.cardDark,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: ColorsApp.border),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child:
                          state is OrdemDeServicoLoadingState
                              ? const Center(
                                child: CircularProgressIndicator(
                                  color: ColorsApp.verdeToast,
                                ),
                              )
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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ordens de Serviço',
                style: TextStyle(
                  color: ColorsApp.textForeground,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Gerencie todas as ordens de serviço da oficina',
                style: TextStyle(color: ColorsApp.textMuted, fontSize: 14),
              ),
            ],
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdicionarOrdemView()),
              ).then((_) => _loadData());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorsApp.verdeToast,
              foregroundColor: ColorsApp.preto,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            icon: const Icon(Icons.add, size: 18),
            label: const Text(
              'Nova OS',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(List<OrdemDeServicoModel> todasOrdens) {
    final Map<StatusOrdemDeServico?, int> statusCounts = {null: todasOrdens.length};

    for (var status in StatusOrdemDeServico.values) {
      statusCounts[status] = todasOrdens.where((o) => o.status == status).length;
    }

    final List<StatusOrdemDeServico?> abas = [null, ...StatusOrdemDeServico.values];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: abas.map((status) {
              final isSelected = _statusFilter == status;
              final label = status == null ? 'Todas' : _getStatusConfig(status).label;
              final count = statusCounts[status] ?? 0;

              return InkWell(
                onTap: () => setState(() => _statusFilter = status),
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? ColorsApp.border : ColorsApp.cardDark,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isSelected ? ColorsApp.textMuted : ColorsApp.border,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          color:
                              isSelected
                                  ? ColorsApp.textForeground
                                  : ColorsApp.textMuted,
                          fontSize: 12,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? ColorsApp.textForeground.withOpacity(0.2)
                                  : ColorsApp.textMuted.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$count',
                          style: TextStyle(
                            color:
                                isSelected
                                    ? ColorsApp.textForeground
                                    : ColorsApp.textMuted,
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
          SizedBox(
            width: 350,
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              style: const TextStyle(color: ColorsApp.textForeground, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Buscar por cliente, veículo, placa...',
                hintStyle: const TextStyle(color: ColorsApp.textMuted),
                prefixIcon: const Icon(
                  Icons.search,
                  color: ColorsApp.textMuted,
                  size: 18,
                ),
                filled: true,
                fillColor: ColorsApp.bgDark,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: ColorsApp.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: ColorsApp.textMuted),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTable(List<OrdemDeServicoModel> ordens) {
    Widget buildCell(Widget child, {int flex = 2}) {
      return Expanded(
        flex: flex,
        child: Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: child,
        ),
      );
    }

    final headers = [
      buildCell(
        const Text(
          'OS',
          style: TextStyle(color: ColorsApp.textMuted, fontWeight: FontWeight.bold),
        ),
        flex: 1,
      ),
      buildCell(
        const Text(
          'Cliente',
          style: TextStyle(color: ColorsApp.textMuted, fontWeight: FontWeight.bold),
        ),
        flex: 2,
      ),
      buildCell(
        const Text(
          'Veículo',
          style: TextStyle(color: ColorsApp.textMuted, fontWeight: FontWeight.bold),
        ),
        flex: 2,
      ),
      buildCell(
        const Text(
          'Serviço',
          style: TextStyle(color: ColorsApp.textMuted, fontWeight: FontWeight.bold),
        ),
        flex: 2,
      ),
      buildCell(
        const Text(
          'Status',
          style: TextStyle(color: ColorsApp.textMuted, fontWeight: FontWeight.bold),
        ),
        flex: 2,
      ),
      buildCell(
        const Text(
          'Valor',
          style: TextStyle(color: ColorsApp.textMuted, fontWeight: FontWeight.bold),
        ),
        flex: 1,
      ),
      buildCell(
        const Text(
          '',
          style: TextStyle(color: ColorsApp.textMuted, fontWeight: FontWeight.bold),
        ),
        flex: 1,
      ),
    ];

    final rows =
        ordens.map((ordem) {
          final configStatus = _getStatusConfig(ordem.status);

          return Row(
            children: [
              buildCell(
                Text(
                  'OS-${ordem.id ?? "000"}',
                  style: const TextStyle(
                    color: ColorsApp.textMuted,
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
                flex: 1,
              ),
              buildCell(
                Text(
                  ordem.cliente ?? 'N/A',
                  style: const TextStyle(
                    color: ColorsApp.textForeground,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                flex: 2,
              ),
              buildCell(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      ordem.carro ?? 'N/A',
                      style: const TextStyle(
                        color: ColorsApp.textForeground,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      ordem.placa ?? '---',
                      style: const TextStyle(color: ColorsApp.textMuted, fontSize: 11),
                    ),
                  ],
                ),
                flex: 2,
              ),
              buildCell(
                Text(
                  ordem.descricaoServico ?? 'N/A',
                  style: const TextStyle(color: ColorsApp.textForeground, fontSize: 13),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                flex: 2,
              ),
              buildCell(
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
                        style: TextStyle(
                          color: configStatus.color,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                flex: 2,
              ),
              buildCell(
                Text(
                  'R\$ ${ordem.valorTotal?.toStringAsFixed(2) ?? "0.00"}',
                  style: const TextStyle(
                    color: ColorsApp.textForeground,
                    fontFamily: 'monospace',
                  ),
                ),
                flex: 1,
              ),
              buildCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.edit_outlined,
                        color: ColorsApp.textMuted,
                        size: 18,
                      ),
                      onPressed: () => _controller.add(EditarOrdemById(ordem)),
                      splashRadius: 20,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: ColorsApp.vermelhoToast,
                        size: 18,
                      ),
                      onPressed:
                          () => _controller.add(DeletarOrdemDeServico(ordem.id!)),
                      splashRadius: 20,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                flex: 1,
              ),
            ],
          );
        }).toList();

    return TableAll(
      headers: headers,
      rows: rows,
      maxRows: 7,
      showActions: false,
      titleEmpty: 'Nenhuma Ordem de Serviço',
      messageEmpty: 'Tente ajustar os filtros ou criar uma nova OS.',
    );
  }

  Widget _buildErrorState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: ColorsApp.vermelhoToast),
          SizedBox(height: 16),
          Text(
            'Não foi possível carregar as ordens de serviço.',
            style: TextStyle(color: ColorsApp.textMuted),
          ),
        ],
      ),
    );
  }

  void _blocListener(BuildContext context, OrdemDeServicoState state) {
    if (state is OrdemDeServicoErrorState) {
      CustomToast.show(context, message: state.message, type: ToastType.error);
    }

    if (state is OrdemDeServicoDeletadaComSucesso) {
      CustomToast.show(
        context,
        message: 'Ordem de serviço deletada com sucesso',
        type: ToastType.success,
      );
      _loadData();
    }
  }

  _StatusConfig _getStatusConfig(StatusOrdemDeServico status) {
    switch (status) {
      case StatusOrdemDeServico.NAO_INICIADO:
        return _StatusConfig('Não Iniciada', ColorsApp.cinza, Icons.schedule);
      case StatusOrdemDeServico.EM_ANDAMENTO:
        return _StatusConfig(
          'Em Andamento',
          ColorsApp.azul,
          Icons.build_circle_outlined,
        );
      case StatusOrdemDeServico.AGUARDANDO_PECA:
        return _StatusConfig(
          'Aguard. Peça',
          ColorsApp.laranja,
          Icons.inventory_2_outlined,
        );
      case StatusOrdemDeServico.AGUARDANDO_RETIRADA:
        return _StatusConfig(
          'Aguard. Retirada',
          ColorsApp.warningNew,
          Icons.hail_outlined,
        );
      case StatusOrdemDeServico.FINALIZADO:
        return _StatusConfig(
          'Concluída',
          ColorsApp.verdeToast,
          Icons.check_circle_outline,
        );
      case StatusOrdemDeServico.CANCELADO:
        return _StatusConfig(
          'Cancelada',
          ColorsApp.vermelhoToast,
          Icons.cancel_outlined,
        );
      default:
        return _StatusConfig(status.name, ColorsApp.textMuted, Icons.help_outline);
    }
  }
}

class _StatusConfig {
  final String label;
  final Color color;
  final IconData icon;

  _StatusConfig(this.label, this.color, this.icon);
}
