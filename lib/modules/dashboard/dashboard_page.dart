import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:oficina_conectada_front/core/constants/app_colors.dart';
import 'package:oficina_conectada_front/modules/dashboard/dashboard_bloc.dart';
import 'package:oficina_conectada_front/modules/dashboard/dashboard_event.dart';
import 'package:oficina_conectada_front/modules/dashboard/dashboard_model.dart';
import 'package:oficina_conectada_front/modules/dashboard/dashboard_service.dart';
import 'package:oficina_conectada_front/modules/dashboard/dashboard_state.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {


  late DashboardBloc _dashboardBloc;
  late DashboardService _dashboardService;


  Color _corPorStatus(String status) {
    if (status == 'FINALIZADO') return AppColors.concluido;
    if (status.contains('AGUARDANDO')) return AppColors.atencao;
    if (status == 'EM_ANDAMENTO') return AppColors.emAndamento;
    return AppColors.textoSecundario;
  }


  @override
  void initState() {
    super.initState();
    _dashboardService = DashboardService();
    _dashboardBloc = DashboardBloc(_dashboardService);
    _dashboardBloc.add(CarregarDashboard());
  }


  Widget _construirHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dashboard',
          style: TextStyle(
            color: AppColors.textoPrincipal,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Visão geral da sua oficina',
          style: TextStyle(color: AppColors.textoSecundario, fontSize: 14),
        ),
      ],
    );
  }

  Widget _construirCardsEstatisticas(DashboardModel dados) {
    final faturamento =
        'R\$ ${dados.faturamentoMensal.toStringAsFixed(2).replaceAll('.', ',')}';

    return Row(
      children: [
        _construirCardStat(
          titulo: 'Faturamento Mensal',
          valor: faturamento,
          etiqueta: 'Atual',
          descricao: 'neste mês',
          subindo: true,
          icone: Icons.attach_money,
        ),
        const SizedBox(width: 16),
        _construirCardStat(
          titulo: 'OS Abertas',
          valor: dados.osAbertas.toString(),
          etiqueta: 'Total',
          descricao: 'no momento',
          subindo: true,
          icone: Icons.content_paste,
        ),
        const SizedBox(width: 16),
        _construirCardStat(
          titulo: 'OS Concluídas',
          valor: dados.osConcluidas.toString(),
          etiqueta: 'Atual',
          descricao: 'este mês',
          subindo: true,
          icone: Icons.check_circle_outline,
        ),
        const SizedBox(width: 16),
        _construirCardStat(
          titulo: 'Veículos em Serviço',
          valor: dados.veiculosEmServico.toString(),
          etiqueta: 'Pátio',
          descricao: 'neste momento',
          subindo: false,
          icone: Icons.directions_car_outlined,
        ),
      ],
    );
  }

  Widget _construirCardStat({
    required String titulo,
    required String valor,
    required String etiqueta,
    required String descricao,
    required bool subindo,
    required IconData icone,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
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
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    color: AppColors.textoSecundario,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.fundoPrincipal,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(icone, color: AppColors.textoPrincipal, size: 16),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              valor,
              style: const TextStyle(
                color: AppColors.textoPrincipal,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  subindo ? Icons.trending_up : Icons.trending_down,
                  color: subindo ? AppColors.primaria : AppColors.atencao,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  etiqueta,
                  style: TextStyle(
                    color: subindo ? AppColors.primaria : AppColors.atencao,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  descricao,
                  style: const TextStyle(color: AppColors.textoSecundario, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirLinhaGraficos(DashboardModel dados) {
    return SizedBox(
      height: 350,
      child: Row(
        children: [
          Expanded(child: _construirGraficoFaturamento(dados.graficoFaturamento)),
          const SizedBox(width: 24),
          Expanded(child: _construirGraficoServicos(dados.graficoServicos)),
        ],
      ),
    );
  }

  Widget _construirGraficoFaturamento(List<FaturamentoMensalModel> dadosFaturamento) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.fundoCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borda),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Faturamento vs Despesas',
            style: TextStyle(
              color: AppColors.textoPrincipal,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Text(
            'Últimos 6 meses (R\$)',
            style: TextStyle(color: AppColors.textoSecundario, fontSize: 13),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SfCartesianChart(
              plotAreaBorderWidth: 0,
              margin: EdgeInsets.zero,
              primaryXAxis: CategoryAxis(
                labelStyle: const TextStyle(color: AppColors.textoSecundario, fontSize: 12),
                majorGridLines: const MajorGridLines(width: 0),
                axisLine: const AxisLine(width: 0),
              ),
              primaryYAxis: NumericAxis(
                labelStyle: const TextStyle(color: AppColors.textoSecundario, fontSize: 12),
                labelFormat: '{value}k',
                majorTickLines: const MajorTickLines(size: 0),
                axisLine: const AxisLine(width: 0),
                majorGridLines: MajorGridLines(
                  width: 1,
                  color: AppColors.textoSecundario.withValues(alpha: 0.1),
                  dashArray: const [5, 5],
                ),
              ),
              tooltipBehavior: TooltipBehavior(enable: true, color: AppColors.fundoPrincipal),
              series: <CartesianSeries<FaturamentoMensalModel, String>>[
                ColumnSeries<FaturamentoMensalModel, String>(
                  dataSource: dadosFaturamento,
                  xValueMapper: (dado, _) => dado.mes,
                  yValueMapper: (dado, _) => dado.receita / 1000,
                  name: 'Receita',
                  color: AppColors.primaria,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
                ColumnSeries<FaturamentoMensalModel, String>(
                  dataSource: dadosFaturamento,
                  xValueMapper: (dado, _) => dado.mes,
                  yValueMapper: (dado, _) => dado.despesa / 1000,
                  name: 'Despesa',
                  color: AppColors.emAndamento,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirGraficoServicos(List<ServicosMensalModel> dadosServicos) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.fundoCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borda),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ordens de Serviço',
            style: TextStyle(
              color: AppColors.textoPrincipal,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Text(
            'Total de OS concluídas por mês',
            style: TextStyle(color: AppColors.textoSecundario, fontSize: 13),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SfCartesianChart(
              plotAreaBorderWidth: 0,
              margin: EdgeInsets.zero,
              primaryXAxis: CategoryAxis(
                labelStyle: const TextStyle(color: AppColors.textoSecundario, fontSize: 12),
                majorGridLines: const MajorGridLines(width: 0),
                axisLine: const AxisLine(width: 0),
              ),
              primaryYAxis: NumericAxis(
                labelStyle: const TextStyle(color: AppColors.textoSecundario, fontSize: 12),
                majorTickLines: const MajorTickLines(size: 0),
                axisLine: const AxisLine(width: 0),
                majorGridLines: MajorGridLines(
                  width: 1,
                  color: AppColors.textoSecundario.withValues(alpha: 0.1),
                  dashArray: const [5, 5],
                ),
              ),
              tooltipBehavior: TooltipBehavior(enable: true, color: AppColors.fundoPrincipal),
              series: <CartesianSeries<ServicosMensalModel, String>>[
                SplineAreaSeries<ServicosMensalModel, String>(
                  dataSource: dadosServicos,
                  xValueMapper: (dado, _) => dado.mes,
                  yValueMapper: (dado, _) => dado.totalOs,
                  name: 'Ordens',
                  borderColor: AppColors.primaria,
                  borderWidth: 2,
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaria.withValues(alpha: 0.3),
                      AppColors.primaria.withValues(alpha: 0.0),
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

  Widget _construirGridInferior(DashboardModel dados) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 2, child: _construirOrdensRecentes(dados.ordensRecentes)),
        const SizedBox(width: 24),
        Expanded(
          flex: 1,
          child: Column(
            children: [
              _construirAgendaHoje(dados.agendamentos),
              const SizedBox(height: 24),
              _construirAlertaEstoqueBaixo(dados.estoqueBaixo),
            ],
          ),
        ),
      ],
    );
  }

  Widget _construirOrdensRecentes(List<OrdemRecenteModel> ordens) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.fundoCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borda),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'Ordens Recentes',
                  style: TextStyle(
                    color: AppColors.textoPrincipal,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      'Ver todas',
                      style: TextStyle(color: AppColors.primaria, fontSize: 13),
                    ),
                    Icon(Icons.arrow_forward, color: AppColors.primaria, size: 14),
                  ],
                ),
              ],
            ),
          ),
          if (ordens.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                'Nenhuma ordem recente encontrada.',
                style: TextStyle(color: AppColors.textoSecundario),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              itemCount: ordens.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final ordem = ordens[i];
                final cor = _corPorStatus(ordem.status);

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.fundoPrincipal.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.borda),
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
                                ordem.codigoOs,
                                style: const TextStyle(
                                  color: AppColors.primaria,
                                  fontSize: 12,
                                  fontFamily: 'monospace',
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: cor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: cor.withValues(alpha: 0.3)),
                                ),
                                child: Text(
                                  ordem.status.replaceAll('_', ' '),
                                  style: TextStyle(color: cor, fontSize: 10),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            ordem.servico,
                            style: const TextStyle(
                              color: AppColors.textoPrincipal,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            ordem.clienteCarro,
                            style: const TextStyle(
                              color: AppColors.textoSecundario,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'Responsável',
                            style: TextStyle(color: AppColors.textoSecundario, fontSize: 12),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.access_time,
                                color: AppColors.textoSecundario,
                                size: 12,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                ordem.tempo,
                                style: const TextStyle(
                                  color: AppColors.textoSecundario,
                                  fontSize: 12,
                                ),
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

  Widget _construirAgendaHoje(List<AgendamentoModel> agenda) {
    final agora = DateTime.now();
    final dataHoje =
        '${agora.day.toString().padLeft(2, '0')}/${agora.month.toString().padLeft(2, '0')}/${agora.year}';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.fundoCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borda),
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
                    color: AppColors.textoPrincipal,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  dataHoje,
                  style: const TextStyle(color: AppColors.textoSecundario, fontSize: 12),
                ),
              ],
            ),
          ),
          if (agenda.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                'Nenhum agendamento para hoje.',
                style: TextStyle(color: AppColors.textoSecundario),
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
                final item = agenda[i];
                final corStatus =
                    item.status == 'CANCELADO' ? AppColors.erro : AppColors.primaria;

                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.fundoPrincipal.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.borda),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.horario,
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
                              item.servico,
                              style: const TextStyle(
                                color: AppColors.textoPrincipal,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.clienteCarro,
                              style: const TextStyle(
                                color: AppColors.textoSecundario,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Mecânico: ${item.mecanico}',
                              style: const TextStyle(
                                color: AppColors.textoSecundario,
                                fontSize: 12,
                              ),
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

  Widget _construirAlertaEstoqueBaixo(List<EstoqueBaixoModel> estoque) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.fundoCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borda),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: AppColors.atencao, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Estoque Baixo',
                      style: TextStyle(
                        color: AppColors.textoPrincipal,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${estoque.length} itens',
                  style: const TextStyle(color: AppColors.atencao, fontSize: 12),
                ),
              ],
            ),
          ),
          if (estoque.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                'Estoque sob controle! Nenhum alerta.',
                style: TextStyle(color: AppColors.primaria),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              itemCount: estoque.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final item = estoque[i];
                final percentual =
                    item.quantidadeMinima > 0 ? item.quantidadeAtual / item.quantidadeMinima : 0.0;

                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.fundoPrincipal.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.borda),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.inventory_2_outlined,
                          color: AppColors.textoSecundario, size: 16),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.nomePeca,
                              style: const TextStyle(
                                color: AppColors.textoPrincipal,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: LinearProgressIndicator(
                                    value: percentual.clamp(0.0, 1.0),
                                    backgroundColor: AppColors.fundoPrincipal,
                                    valueColor: const AlwaysStoppedAnimation<Color>(
                                      AppColors.atencao,
                                    ),
                                    minHeight: 6,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  '${item.quantidadeAtual}/${item.quantidadeMinima}',
                                  style: const TextStyle(
                                    color: AppColors.textoSecundario,
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


  Widget _blocBuilder() {
    return BlocBuilder<DashboardBloc, DashboardState>(
      bloc: _dashboardBloc,
      builder: (context, estado) {
        if (estado is DashboardCarregando || estado is DashboardInicial) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaria),
          );
        }

        if (estado is DashboardErro) {
          return Center(
            child: Text(
              estado.mensagem,
              style: const TextStyle(color: AppColors.erro, fontSize: 16),
            ),
          );
        }

        if (estado is DashboardCarregado) {
          final dados = estado.dados;
          return RefreshIndicator(
            onRefresh: () async => _dashboardBloc.add(CarregarDashboard()),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _construirHeader(),
                  const SizedBox(height: 24),
                  _construirCardsEstatisticas(dados),
                  const SizedBox(height: 24),
                  _construirLinhaGraficos(dados),
                  const SizedBox(height: 24),
                  _construirGridInferior(dados),
                ],
              ),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fundoPrincipal,
      body: _blocBuilder(),
    );
  }


  @override
  void dispose() {
    _dashboardBloc.close();
    super.dispose();
  }
}
