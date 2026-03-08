import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';


//COMO ESTOU MUDANOD FRONT  DO WEB INTEIRO ALGUNS DADOS  ESTAO MOCK
//DEVIDO QUE  ALGUMAS ROTAS NAO ESTÃO FEITAS NO BACK (PRODUTO AINDA ESTÁ SENDO DESENVOLVIDO)



// Cores
const Color _bgDark = Color(0xFF09090B);
const Color _cardDark = Color(0xFF18181B);
const Color _border = Color(0xFF27272A);
const Color _textForeground = Color(0xFFFAFAFA);
const Color _textMuted = Color(0xFFA1A1AA);

// Cores dos Gráficos e Badges
const Color _green = Color(0xFF4ADE80);
const Color _blue = Color(0xFF60A5FA);
const Color _emerald = Color(0xFF34D399);
const Color _warning = Color(0xFFF59E0B);
const Color _destructive = Color(0xFFEF4444);

class DashBoardPage extends StatelessWidget {
  const DashBoardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDark,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildStatsCards(),
            const SizedBox(height: 24),
            _buildChartsRow(),
            const SizedBox(height: 24),
            _buildBottomGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Dashboard',
          style: TextStyle(color: _textForeground, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 4),
        Text('Visão geral da sua oficina', style: TextStyle(color: _textMuted, fontSize: 14)),
      ],
    );
  }

  Widget _buildStatsCards() {
    return Row(
      children: [
        _buildSingleStatCard(
          title: 'Faturamento Mensal',
          value: 'R\$ 48.750',
          change: '+12,5%',
          desc: 'vs. mês anterior',
          isUp: true,
          icon: Icons.attach_money,
        ),
        const SizedBox(width: 16),
        _buildSingleStatCard(
          title: 'OS Abertas',
          value: '12',
          change: '+3',
          desc: 'esta semana',
          isUp: true,
          icon: Icons.content_paste,
        ),
        const SizedBox(width: 16),
        _buildSingleStatCard(
          title: 'OS Concluídas',
          value: '34',
          change: '+8',
          desc: 'este mês',
          isUp: true,
          icon: Icons.check_circle_outline,
        ),
        const SizedBox(width: 16),
        _buildSingleStatCard(
          title: 'Veículos em Serviço',
          value: '7',
          change: '-2',
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
          color: _cardDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _border),
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
                    color: _textMuted,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: _bgDark, borderRadius: BorderRadius.circular(6)),
                  child: Icon(icon, color: _textForeground, size: 16),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                color: _textForeground,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  isUp ? Icons.trending_up : Icons.trending_down,
                  color: isUp ? _green : _warning,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  change,
                  style: TextStyle(
                    color: isUp ? _green : _warning,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                Text(desc, style: const TextStyle(color: _textMuted, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartsRow() {
    return SizedBox(
      height: 350,
      child: Row(
        children: [
          Expanded(child: _buildRevenueChart()),
          const SizedBox(width: 24),
          Expanded(child: _buildServicesChart()),
        ],
      ),
    );
  }

  Widget _buildRevenueChart() {
    final List<Map<String, dynamic>> revenueData = [
      {'month': 'Set', 'receita': 32400, 'despesa': 18200},
      {'month': 'Out', 'receita': 38100, 'despesa': 20100},
      {'month': 'Nov', 'receita': 41300, 'despesa': 19800},
      {'month': 'Dez', 'receita': 35600, 'despesa': 22400},
      {'month': 'Jan', 'receita': 43200, 'despesa': 21000},
      {'month': 'Fev', 'receita': 48750, 'despesa': 23500},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Faturamento vs Despesas',
            style: TextStyle(color: _textForeground, fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const Text('Últimos 6 meses (R\$)', style: TextStyle(color: _textMuted, fontSize: 13)),
          const SizedBox(height: 16),
          Expanded(
            child: SfCartesianChart(
              plotAreaBorderWidth: 0,
              margin: EdgeInsets.zero,
              primaryXAxis: CategoryAxis(
                labelStyle: const TextStyle(color: _textMuted, fontSize: 12),
                majorGridLines: const MajorGridLines(width: 0),
                axisLine: const AxisLine(width: 0),
              ),
              primaryYAxis: NumericAxis(
                labelStyle: const TextStyle(color: _textMuted, fontSize: 12),
                labelFormat: '{value}k',
                majorTickLines: const MajorTickLines(size: 0),
                axisLine: const AxisLine(width: 0),
                majorGridLines: MajorGridLines(
                  width: 1,
                  color: _textMuted.withOpacity(0.1),
                  dashArray: const [5, 5],
                ),
              ),
              tooltipBehavior: TooltipBehavior(enable: true, color: _bgDark),
              series: <CartesianSeries<Map<String, dynamic>, String>>[
                ColumnSeries<Map<String, dynamic>, String>(
                  dataSource: revenueData,
                  xValueMapper: (data, _) => data['month'] as String,
                  yValueMapper: (data, _) => (data['receita'] as int) / 1000,
                  name: 'Receita',
                  color: _green,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
                ColumnSeries<Map<String, dynamic>, String>(
                  dataSource: revenueData,
                  xValueMapper: (data, _) => data['month'] as String,
                  yValueMapper: (data, _) => (data['despesa'] as int) / 1000,
                  name: 'Despesa',
                  color: _blue,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesChart() {
    final List<Map<String, dynamic>> servicesData = [
      {'month': 'Set', 'os': 28},
      {'month': 'Out', 'os': 35},
      {'month': 'Nov', 'os': 42},
      {'month': 'Dez', 'os': 31},
      {'month': 'Jan', 'os': 38},
      {'month': 'Fev', 'os': 46},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ordens de Serviço',
            style: TextStyle(color: _textForeground, fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const Text(
            'Total de OS concluídas por mês',
            style: TextStyle(color: _textMuted, fontSize: 13),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SfCartesianChart(
              plotAreaBorderWidth: 0,
              margin: EdgeInsets.zero,
              primaryXAxis: CategoryAxis(
                labelStyle: const TextStyle(color: _textMuted, fontSize: 12),
                majorGridLines: const MajorGridLines(width: 0),
                axisLine: const AxisLine(width: 0),
              ),
              primaryYAxis: NumericAxis(
                labelStyle: const TextStyle(color: _textMuted, fontSize: 12),
                majorTickLines: const MajorTickLines(size: 0),
                axisLine: const AxisLine(width: 0),
                majorGridLines: MajorGridLines(
                  width: 1,
                  color: _textMuted.withOpacity(0.1),
                  dashArray: const [5, 5],
                ),
              ),
              tooltipBehavior: TooltipBehavior(enable: true, color: _bgDark),
              series: <CartesianSeries<Map<String, dynamic>, String>>[
                SplineAreaSeries<Map<String, dynamic>, String>(
                  dataSource: servicesData,
                  xValueMapper: (data, _) => data['month'] as String,
                  yValueMapper: (data, _) => data['os'] as int,
                  name: 'Ordens',
                  borderColor: _emerald,
                  borderWidth: 2,
                  gradient: LinearGradient(
                    colors: [_emerald.withOpacity(0.3), _emerald.withOpacity(0.0)],
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

  Widget _buildBottomGrid() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 2, child: _buildRecentOrders()),
        const SizedBox(width: 24),
        Expanded(
          flex: 1,
          child: Column(
            children: [_buildTodaySchedule(), const SizedBox(height: 24), _buildLowStockAlert()],
          ),
        ),
      ],
    );
  }

  Widget _buildRecentOrders() {
    final orders = [
      {
        'id': 'OS-2026-0147',
        'service': 'Troca de embreagem',
        'client': 'Carlos Silva',
        'car': 'Honda Civic 2022 (BRA-2E19)',
        'mec': 'Joao',
        'time': '2h atras',
        'status': 'Em Andamento',
        'color': _blue,
      },
      {
        'id': 'OS-2026-0146',
        'service': 'Revisão completa 60.000km',
        'client': 'Ana Oliveira',
        'car': 'Toyota Corolla 2021 (RIO-4A32)',
        'mec': 'Pedro',
        'time': '3h atras',
        'status': 'Aguard. Peça',
        'color': _warning,
      },
      {
        'id': 'OS-2026-0145',
        'service': 'Troca de pastilhas de freio',
        'client': 'Roberto Santos',
        'car': 'VW Golf 2020 (SAO-7B55)',
        'mec': 'Lucas',
        'time': '5h atras',
        'status': 'Concluída',
        'color': _emerald,
      },
      {
        'id': 'OS-2026-0144',
        'service': 'Alinhamento e balanceamento',
        'client': 'Maria Fernandes',
        'car': 'Fiat Argo 2023 (MIS-3C88)',
        'mec': 'Joao',
        'time': '6h atras',
        'status': 'Em Andamento',
        'color': _blue,
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
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
                    color: _textForeground,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: const [
                    Text('Ver todas', style: TextStyle(color: _green, fontSize: 13)),
                    Icon(Icons.arrow_forward, color: _green, size: 14),
                  ],
                ),
              ],
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final o = orders[i];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _bgDark.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _border),
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
                              o['id'] as String,
                              style: const TextStyle(
                                color: _green,
                                fontSize: 12,
                                fontFamily: 'monospace',
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: (o['color'] as Color).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: (o['color'] as Color).withOpacity(0.3)),
                              ),
                              child: Text(
                                o['status'] as String,
                                style: TextStyle(color: o['color'] as Color, fontSize: 10),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          o['service'] as String,
                          style: const TextStyle(
                            color: _textForeground,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${o['client']} - ${o['car']}',
                          style: const TextStyle(color: _textMuted, fontSize: 12),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Mec. ${o['mec']}',
                          style: const TextStyle(color: _textMuted, fontSize: 12),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.access_time, color: _textMuted, size: 12),
                            const SizedBox(width: 4),
                            Text(
                              o['time'] as String,
                              style: const TextStyle(color: _textMuted, fontSize: 12),
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

  Widget _buildTodaySchedule() {
    final schedule = [
      {
        'time': '08:00',
        'service': 'Troca de óleo',
        'client': 'Fernando Lima - Hyundai HB20',
        'mec': 'João',
        'color': _green,
      },
      {
        'time': '09:30',
        'service': 'Revisão 20.000km',
        'client': 'Juliana Costa - Renault Kwid',
        'mec': 'Pedro',
        'color': _green,
      },
      {
        'time': '11:00',
        'service': 'Barulho na suspensão',
        'client': 'Ricardo Alves - Jeep Compass',
        'mec': 'Lucas',
        'color': _green,
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'Agenda de Hoje',
                  style: TextStyle(
                    color: _textForeground,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text('02/03/2026', style: TextStyle(color: _textMuted, fontSize: 12)),
              ],
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            itemCount: schedule.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final s = schedule[i];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _bgDark.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _border),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s['time'] as String,
                      style: TextStyle(
                        color: s['color'] as Color,
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
                            s['service'] as String,
                            style: const TextStyle(
                              color: _textForeground,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            s['client'] as String,
                            style: const TextStyle(color: _textMuted, fontSize: 12),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Mecânico: ${s['mec']}',
                            style: const TextStyle(color: _textMuted, fontSize: 12),
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

  Widget _buildLowStockAlert() {
    final stock = [
      {'name': 'Filtro de Óleo - Mann W7008', 'qty': 2, 'min': 10},
      {'name': 'Pastilha de Freio - TRW Diant.', 'qty': 3, 'min': 8},
      {'name': 'Correia Dentada - Gates Civic', 'qty': 1, 'min': 5},
    ];

    return Container(
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
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
                    Icon(Icons.warning_amber_rounded, color: _warning, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Estoque Baixo',
                      style: TextStyle(
                        color: _textForeground,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const Text('5 itens', style: TextStyle(color: _warning, fontSize: 12)),
              ],
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            itemCount: stock.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final item = stock[i];
              final qty = item['qty'] as int;
              final min = item['min'] as int;
              final percent = (qty / min);

              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _bgDark.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.inventory_2_outlined, color: _textMuted, size: 16),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['name'] as String,
                            style: const TextStyle(color: _textForeground, fontSize: 13),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: LinearProgressIndicator(
                                  value: percent,
                                  backgroundColor: _bgDark,
                                  valueColor: AlwaysStoppedAnimation<Color>(_warning),
                                  minHeight: 6,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '$qty/$min',
                                style: const TextStyle(
                                  color: _textMuted,
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
