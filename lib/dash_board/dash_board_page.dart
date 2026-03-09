import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../colors/colors.dart';
import '../model/model_dash_board/dash_board_model.dart';
import 'dash_board_bloc.dart';
import 'dash_board_event.dart';
import 'dash_board_repository.dart';
import 'dash_board_state.dart';

class DashBoardPage extends StatefulWidget {
  const DashBoardPage({super.key});

  @override
  State<DashBoardPage> createState() => _DashBoardPageState();
}

class _DashBoardPageState extends State<DashBoardPage> {
  late DashboardBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = DashboardBloc(DashBoardRepository());
    _bloc.add(CarregarDashboard());
  }

  Color _corPorStatus(String status) {
    if (status == 'FINALIZADO') return ColorsApp.emeraldNew;
    if (status.contains('AGUARDANDO')) return ColorsApp.warningNew;
    if (status == 'EM_ANDAMENTO') return ColorsApp.blueNew;
    return ColorsApp.textMuted;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsApp.bgDark,
      body: BlocBuilder<DashboardBloc, DashboardState>(
        bloc: _bloc,
        builder: (context, state) {
          if (state is DashboardLoading || state is DashboardInitial) {
            return const Center(child: CircularProgressIndicator(color: ColorsApp.greenNew));
          }

          if (state is DashboardError) {
            return Center(
              child: Text(
                state.mensagem,
                style: const TextStyle(color: ColorsApp.vermelhoToast, fontSize: 16),
              ),
            );
          }

          if (state is DashboardLoaded) {
            final dados = state.dados;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildStatsCards(dados),
                  const SizedBox(height: 24),
                  _buildChartsRow(dados),
                  const SizedBox(height: 24),
                  _buildBottomGrid(dados),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Dashboard',
          style: TextStyle(
            color: ColorsApp.textForeground,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Visão geral da sua oficina',
          style: TextStyle(color: ColorsApp.textMuted, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildStatsCards(DashboardModel dados) {
    String faturamento = 'R\$ ${dados.faturamentoMensal.toStringAsFixed(2).replaceAll('.', ',')}';

    return Row(
      children: [
        _buildSingleStatCard(
          title: 'Faturamento Mensal',
          value: faturamento,
          change: 'Atual',
          desc: 'neste mês',
          isUp: true,
          icon: Icons.attach_money,
        ),
        const SizedBox(width: 16),
        _buildSingleStatCard(
          title: 'OS Abertas',
          value: dados.osAbertas.toString(),
          change: 'Total',
          desc: 'no momento',
          isUp: true,
          icon: Icons.content_paste,
        ),
        const SizedBox(width: 16),
        _buildSingleStatCard(
          title: 'OS Concluídas',
          value: dados.osConcluidas.toString(),
          change: 'Atual',
          desc: 'este mês',
          isUp: true,
          icon: Icons.check_circle_outline,
        ),
        const SizedBox(width: 16),
        _buildSingleStatCard(
          title: 'Veículos em Serviço',
          value: dados.veiculosEmServico.toString(),
          change: 'Pátio',
          desc: 'neste momento',
          isUp: false,
          icon: Icons.directions_car_outlined,
        ),
      ],
    );
  }

  Widget _buildSingleStatCard({
    required String title,
    required String value,
    required String change,
    required String desc,
    required bool isUp,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: ColorsApp.cardDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ColorsApp.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: ColorsApp.textMuted,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: ColorsApp.bgDark,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(icon, color: ColorsApp.textForeground, size: 16),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                color: ColorsApp.textForeground,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  isUp ? Icons.trending_up : Icons.trending_down,
                  color: isUp ? ColorsApp.greenNew : ColorsApp.warningNew,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  change,
                  style: TextStyle(
                    color: isUp ? ColorsApp.greenNew : ColorsApp.warningNew,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                Text(desc, style: const TextStyle(color: ColorsApp.textMuted, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartsRow(DashboardModel dados) {
    return SizedBox(
      height: 350,
      child: Row(
        children: [
          Expanded(child: _buildRevenueChart(dados.graficoFaturamento)),
          const SizedBox(width: 24),
          Expanded(child: _buildServicesChart(dados.graficoServicos)),
        ],
      ),
    );
  }

  Widget _buildRevenueChart(List<FaturamentoMensalModel> revenueData) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ColorsApp.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorsApp.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Faturamento vs Despesas',
            style: TextStyle(
              color: ColorsApp.textForeground,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Text(
            'Últimos 6 meses (R\$)',
            style: TextStyle(color: ColorsApp.textMuted, fontSize: 13),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SfCartesianChart(
              plotAreaBorderWidth: 0,
              margin: EdgeInsets.zero,
              primaryXAxis: CategoryAxis(
                labelStyle: const TextStyle(color: ColorsApp.textMuted, fontSize: 12),
                majorGridLines: const MajorGridLines(width: 0),
                axisLine: const AxisLine(width: 0),
              ),
              primaryYAxis: NumericAxis(
                labelStyle: const TextStyle(color: ColorsApp.textMuted, fontSize: 12),
                labelFormat: '{value}k',
                majorTickLines: const MajorTickLines(size: 0),
                axisLine: const AxisLine(width: 0),
                majorGridLines: MajorGridLines(
                  width: 1,
                  color: ColorsApp.textMuted.withOpacity(0.1),
                  dashArray: const [5, 5],
                ),
              ),
              tooltipBehavior: TooltipBehavior(enable: true, color: ColorsApp.bgDark),
              series: <CartesianSeries<FaturamentoMensalModel, String>>[
                ColumnSeries<FaturamentoMensalModel, String>(
                  dataSource: revenueData,
                  xValueMapper: (data, _) => data.mes,
                  yValueMapper: (data, _) => data.receita / 1000,
                  name: 'Receita',
                  color: ColorsApp.greenNew,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
                ColumnSeries<FaturamentoMensalModel, String>(
                  dataSource: revenueData,
                  xValueMapper: (data, _) => data.mes,
                  yValueMapper: (data, _) => data.despesa / 1000,
                  name: 'Despesa',
                  color: ColorsApp.blueNew,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesChart(List<ServicosMensalModel> servicesData) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ColorsApp.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorsApp.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ordens de Serviço',
            style: TextStyle(
              color: ColorsApp.textForeground,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Text(
            'Total de OS concluídas por mês',
            style: TextStyle(color: ColorsApp.textMuted, fontSize: 13),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SfCartesianChart(
              plotAreaBorderWidth: 0,
              margin: EdgeInsets.zero,
              primaryXAxis: CategoryAxis(
                labelStyle: const TextStyle(color: ColorsApp.textMuted, fontSize: 12),
                majorGridLines: const MajorGridLines(width: 0),
                axisLine: const AxisLine(width: 0),
              ),
              primaryYAxis: NumericAxis(
                labelStyle: const TextStyle(color: ColorsApp.textMuted, fontSize: 12),
                majorTickLines: const MajorTickLines(size: 0),
                axisLine: const AxisLine(width: 0),
                majorGridLines: MajorGridLines(
                  width: 1,
                  color: ColorsApp.textMuted.withOpacity(0.1),
                  dashArray: const [5, 5],
                ),
              ),
              tooltipBehavior: TooltipBehavior(enable: true, color: ColorsApp.bgDark),
              series: <CartesianSeries<ServicosMensalModel, String>>[
                SplineAreaSeries<ServicosMensalModel, String>(
                  dataSource: servicesData,
                  xValueMapper: (data, _) => data.mes,
                  yValueMapper: (data, _) => data.totalOs,
                  name: 'Ordens',
                  borderColor: ColorsApp.emeraldNew,
                  borderWidth: 2,
                  gradient: LinearGradient(
                    colors: [
                      ColorsApp.emeraldNew.withOpacity(0.3),
                      ColorsApp.emeraldNew.withOpacity(0.0),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomGrid(DashboardModel dados) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 2, child: _buildRecentOrders(dados.ordensRecentes)),
        const SizedBox(width: 24),
        Expanded(
          flex: 1,
          child: Column(
            children: [
              _buildTodaySchedule(dados.agendamentos), // <-- Agora passamos a lista real!
              const SizedBox(height: 24),
              _buildLowStockAlert(dados.estoqueBaixo),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecentOrders(List<OrdemRecenteModel> orders) {
    return Container(
      decoration: BoxDecoration(
        color: ColorsApp.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorsApp.border),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Ordens Recentes',
                  style: TextStyle(
                    color: ColorsApp.textForeground,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: const [
                    Text('Ver todas', style: TextStyle(color: ColorsApp.greenNew, fontSize: 13)),
                    Icon(Icons.arrow_forward, color: ColorsApp.greenNew, size: 14),
                  ],
                ),
              ],
            ),
          ),
          if (orders.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                'Nenhuma ordem recente encontrada.',
                style: TextStyle(color: ColorsApp.textMuted),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              itemCount: orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final o = orders[i];
                final color = _corPorStatus(o.status);

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: ColorsApp.bgDark.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: ColorsApp.border),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                o.codigoOs,
                                style: const TextStyle(
                                  color: ColorsApp.greenNew,
                                  fontSize: 12,
                                  fontFamily: 'monospace',
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: color.withOpacity(0.3)),
                                ),
                                child: Text(
                                  o.status.replaceAll('_', ' '),
                                  // tira o underline para ficar mais limpo
                                  style: TextStyle(color: color, fontSize: 10),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            o.servico,
                            style: const TextStyle(
                              color: ColorsApp.textForeground,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            o.clienteCarro,
                            style: const TextStyle(color: ColorsApp.textMuted, fontSize: 12),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'Responsável', // Fixo por enquanto, pois não tem mecânico no DTO ainda
                            style: TextStyle(color: ColorsApp.textMuted, fontSize: 12),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.access_time, color: ColorsApp.textMuted, size: 12),
                              const SizedBox(width: 4),
                              Text(
                                o.tempo,
                                style: const TextStyle(color: ColorsApp.textMuted, fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildTodaySchedule(List<AgendamentoModel> agenda) {
    final agora = DateTime.now();
    final dataHojeStr =
        "${agora.day.toString().padLeft(2, '0')}/${agora.month.toString().padLeft(2, '0')}/${agora.year}";

    return Container(
      decoration: BoxDecoration(
        color: ColorsApp.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorsApp.border),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Agenda de Hoje',
                  style: TextStyle(
                    color: ColorsApp.textForeground,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(dataHojeStr, style: const TextStyle(color: ColorsApp.textMuted, fontSize: 12)),
              ],
            ),
          ),
          if (agenda.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                'Nenhum agendamento para hoje.',
                style: TextStyle(color: ColorsApp.textMuted),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              itemCount: agenda.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final s = agenda[i];
                Color corStatus = ColorsApp.greenNew;
                if (s.status == 'CANCELADO') corStatus = ColorsApp.vermelhoToast;

                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: ColorsApp.bgDark.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: ColorsApp.border),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.horario,
                        style: TextStyle(
                          color: corStatus,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s.servico,
                              style: const TextStyle(
                                color: ColorsApp.textForeground,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              s.clienteCarro,
                              style: const TextStyle(color: ColorsApp.textMuted, fontSize: 12),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Mecânico: ${s.mecanico}',
                              style: const TextStyle(color: ColorsApp.textMuted, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildLowStockAlert(List<EstoqueBaixoModel> stock) {
    return Container(
      decoration: BoxDecoration(
        color: ColorsApp.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorsApp.border),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(Icons.warning_amber_rounded, color: ColorsApp.warningNew, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Estoque Baixo',
                      style: TextStyle(
                        color: ColorsApp.textForeground,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${stock.length} itens',
                  style: const TextStyle(color: ColorsApp.warningNew, fontSize: 12),
                ),
              ],
            ),
          ),
          if (stock.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                'Estoque sob controle! Nenhum alerta.',
                style: TextStyle(color: ColorsApp.greenNew),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              itemCount: stock.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final item = stock[i];
                final qty = item.quantidadeAtual;
                final min = item.quantidadeMinima;

                // evito divisão por zero caso o min venha zerado do banco
                final percent = min > 0 ? (qty / min) : 0.0;

                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: ColorsApp.bgDark.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: ColorsApp.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.inventory_2_outlined, color: ColorsApp.textMuted, size: 16),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.nomePeca,
                              style: const TextStyle(color: ColorsApp.textForeground, fontSize: 13),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: LinearProgressIndicator(
                                    value: percent.clamp(0.0, 1.0),
                                    backgroundColor: ColorsApp.bgDark,
                                    valueColor: const AlwaysStoppedAnimation<Color>(
                                      ColorsApp.warningNew,
                                    ),
                                    minHeight: 6,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  '$qty/$min',
                                  style: const TextStyle(
                                    color: ColorsApp.textMuted,
                                    fontSize: 11,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
