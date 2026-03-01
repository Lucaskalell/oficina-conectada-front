import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oficina_conectada_front/dash_board/dash_board_bloc.dart';
import 'package:oficina_conectada_front/dash_board/dash_board_event.dart';
import 'package:oficina_conectada_front/dash_board/dash_board_repository.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../colors/colors.dart';
import '../model/model_dash_board/OrdemServicoMock.dart';
import '../model/model_dash_board/dash_board_model.dart';
import '../model/model_dash_board/dash_board_semana.dart';
import '../strings/oficina_strings.dart';
import 'dash_board_state.dart';

class DashBoardPage extends StatefulWidget {
  const DashBoardPage({super.key});
  @override
  State<DashBoardPage> createState() => _DashBoardPageState();
}

class _DashBoardPageState extends State<DashBoardPage> {
  late DashboardBloc _dashboardBloc;

  void _loadData() {
    _dashboardBloc.add(CarregarDashboard());
  }

  @override
  void initState() {
    super.initState();
    _dashboardBloc = DashboardBloc(DashBoardRepository());
    _loadData();
  }

  Widget _buildTitle() {
    return const Text(
      OficinaStrings.visaoGeral,
      style: TextStyle(color: ColorsApp.branco, fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildKpiSection(DashboardData data) {
    return Row(
      children: [
        _KpiCard(
          title: OficinaStrings.faturamentoMes,
          value: 'R\$ ${data.faturamentoMensal.toStringAsFixed(2)}',
          icon: Icons.monetization_on,
          color: ColorsApp.verde,
        ),
        const SizedBox(width: 16),
        _KpiCard(
          title: OficinaStrings.osAbertas,
          value: '${data.totalOrdensAbertas}',
          icon: Icons.build,
          color: ColorsApp.laranja,
          onTap: () => _mostrarModalOrdens(context),
        ),
        const SizedBox(width: 16),
        _KpiCard(
          title: OficinaStrings.estoqueCritico,
          value: '${data.produtosBaixoEstoque} Itens',
          icon: Icons.warning,
          color: ColorsApp.vermelho,
        ),
      ],
    );
  }

  Widget _buildChartsSection(DashboardData data) {
    return SizedBox(
      height: 400,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 2, child: _buildVendasChart(data.vendasSemana)),
          const SizedBox(width: 16),
          Expanded(child: _buildStatusChart(data.statusOrdens)),
        ],
      ),
    );
  }

  Widget _buildVendasChart(List<VendaSemana> vendas) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: ColorsApp.preto, borderRadius: BorderRadius.circular(16)),
      child: SfCartesianChart(
        title: ChartTitle(
          text: OficinaStrings.faturamentoSemanal,
          textStyle: const TextStyle(color: ColorsApp.branco, fontSize: 14),
        ),
        primaryXAxis: CategoryAxis(labelStyle: const TextStyle(color: ColorsApp.cinza)),
        primaryYAxis: NumericAxis(labelStyle: const TextStyle(color: ColorsApp.cinza)),
        tooltipBehavior: TooltipBehavior(enable: true, header: '', canShowMarker: false),
        series: <CartesianSeries<VendaSemana, String>>[
          ColumnSeries<VendaSemana, String>(
            dataSource: vendas,
            xValueMapper: (VendaSemana sales, _) => sales.dia,
            yValueMapper: (VendaSemana sales, _) => sales.valor,
            name: OficinaStrings.vendas,
            color: ColorsApp.azulClaro,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChart(Map<String, int> statusMap) {
    final List<_ChartData> data = statusMap.entries.map((entry) {
      final String key = entry.key.toLowerCase();
      Color color;
      if (key.contains('conclu')) {
        color = ColorsApp.verdeEscuro;
      } else if (key.contains('andamento')) {
        color = Colors.blueAccent;
      } else if (key.contains('pendente')) {
        color = ColorsApp.laranja;
      } else {
        color = Colors.grey;
      }
      final String label = entry.key;

      return _ChartData(label, entry.value.toDouble(), color: color);
    }).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: SfCircularChart(
        title: ChartTitle(
          text: OficinaStrings.statusDaOs,
          textStyle: const TextStyle(color: ColorsApp.branco, fontSize: 14),
        ),
        legend: Legend(
          isVisible: true,
          textStyle: const TextStyle(color: ColorsApp.branco),
          position: LegendPosition.bottom,
        ),
        series: <CircularSeries>[
          DoughnutSeries<_ChartData, String>(
            dataSource: data,
            xValueMapper: (_ChartData d, _) => d.x,
            yValueMapper: (_ChartData d, _) => d.y,
            pointColorMapper: (_ChartData d, _) => d.color,
            innerRadius: '50%',
            dataLabelSettings: const DataLabelSettings(
              isVisible: true,
              textStyle: TextStyle(color: ColorsApp.branco, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(DashboardData data) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitle(),
          const SizedBox(height: 20),
          _buildKpiSection(data),
          const SizedBox(height: 30),
          _buildChartsSection(data),
        ],
      ),
    );
  }


  Widget _buildError(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: ColorsApp.vermelho, size: 40),
          const SizedBox(height: 10),
          Text(message, style: const TextStyle(color: ColorsApp.branco)),
          const SizedBox(height: 10),
          ElevatedButton(onPressed: _loadData, child: const Text(OficinaStrings.tentarNovamente)),
        ],
      ),
    );
  }

  Widget _blocBuilder() {
    return BlocBuilder<DashboardBloc, DashboardState>(
      bloc: _dashboardBloc,
      builder: (context, state) {
        if (state is DashboardLoading) {
          return const Center(child: CircularProgressIndicator(color: ColorsApp.azulClaro));
        } else if (state is DashboardLoaded) {
          return _buildBody(state.data);
        } else if (state is DashboardError) {
          return _buildError(state.message);
        }
        return const SizedBox.shrink();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.transparent, body: _blocBuilder());
  }

  @override
  void dispose() {
    _dashboardBloc.close();
    super.dispose();
  }

  void _mostrarModalOrdens(BuildContext context) {
    final List<OrdemServicoMock> listaOS = [
      OrdemServicoMock(
        id: 1,
        cliente: 'Lucas Tomioka',
        carro: 'Honda Civic',
        placa: 'ABC-1234',
        servicos: 'Troca de óleo',
        valorPecas: 200,
        valorMaoDeObra: 100,
        status: StatusOS.emAndamento,
      ),
      OrdemServicoMock(
        id: 2,
        cliente: 'Tanjiro Kamado',
        carro: 'Jeep Renegade',
        placa: 'KAT-9999',
        servicos: 'Alinhamento',
        valorPecas: 0,
        valorMaoDeObra: 150,
        status: StatusOS.emEspera,
      ),
      OrdemServicoMock(
        id: 3,
        cliente: 'Zenitsu Agatsuma',
        carro: 'Fiat Uno Escada',
        placa: 'RAY-0000',
        servicos: 'Motor completo, Freios',
        valorPecas: 1500,
        valorMaoDeObra: 800,
        status: StatusOS.concluido,
      ),
      OrdemServicoMock(
        id: 4,
        cliente: 'Naruto Uzumaki',
        carro: 'Toyota Corolla',
        placa: 'ABC-1234',
        servicos: 'Troca de óleo',
        valorPecas: 200,
        valorMaoDeObra: 50,
        status: StatusOS.concluido,
      ),
    ];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Text(OficinaStrings.ordensEmAberto, style: TextStyle(color: ColorsApp.branco)),
          content: SizedBox(
            width: 500,
            height: 400,
            child: ListView.builder(
              itemCount: listaOS.length,
              itemBuilder: (context, index) {
                final os = listaOS[index];
                return _buildOsItem(context, os);
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(OficinaStrings.fechar, style: TextStyle(color: ColorsApp.cinza)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOsItem(BuildContext context, OrdemServicoMock os) {
    IconData icon;
    Color color;
    Widget trailing;

    switch (os.status) {
      case StatusOS.emAndamento:
        icon = Icons.elevator;
        color = Colors.blueAccent;
        trailing = const Tooltip(
          message: OficinaStrings.noElevadorEmServico,
          child: Icon(Icons.build, color: Colors.blueAccent),
        );
        break;
      case StatusOS.emEspera:
        icon = Icons.garage;
        color = Colors.orangeAccent;
        trailing = const Tooltip(
          message: OficinaStrings.noPatioAguardando,
          child: Icon(Icons.access_time, color: Colors.orangeAccent),
        );
        break;
      case StatusOS.concluido:
        icon = Icons.check_circle_outline;
        color = Colors.greenAccent;
        trailing = Checkbox(
          value: false,
          activeColor: Colors.green,
          side: const BorderSide(color: Colors.greenAccent),
          onChanged: (val) {
            if (val == true) {
              _confirmarEnvioMensagem(context, os);
            }
          },
        );
        break;
    }

    return Card(
      color: Colors.grey.shade900,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: color, size: 32),
        title: Text(
          '${os.carro} - ${os.placa}',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(os.cliente, style: TextStyle(color: Colors.grey.shade400)),
        trailing: trailing,
      ),
    );
  }

  void _confirmarEnvioMensagem(BuildContext context, OrdemServicoMock os) {
    final String mensagem =
        'Olá ${os.cliente}, seu carro (${os.carro}) está pronto! \n'
        '🛠️ Serviços: ${os.servicos}\n'
        '🔩 Peças: R\$ ${os.valorPecas.toStringAsFixed(2)}\n'
        '🔧 Mão de Obra: R\$ ${os.valorMaoDeObra.toStringAsFixed(2)}\n'
        '💰 TOTAL: R\$ ${os.total.toStringAsFixed(2)}\n\n'
        'Placa: ${os.placa}\n'
        'Pagamento: Débito, Crédito ou PIX.\n'
        'A Oficina do Tomioka agradece! 🌊';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF252526),
          title: const Row(
            children: [
              Icon(Icons.phone_android, color: Colors.green, size: 28),
              SizedBox(width: 10),
              Text('Avisar Cliente', style: TextStyle(color: Colors.white)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                OficinaStrings.desejaFinalizarOSeEnviarEstaMensagem,
                style: TextStyle(color: ColorsApp.cinza),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black38,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Text(
                  mensagem,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(OficinaStrings.cancelar, style: TextStyle(color: Colors.redAccent)),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              icon: const Icon(Icons.send, color: Colors.white, size: 18),
              label: const Text(OficinaStrings.simEnviar, style: TextStyle(color: Colors.white)),
              onPressed: () {
                debugPrint('${OficinaStrings.enviandoMensagemPara} ${os.cliente}...');
                // TODO: Chamar BLoC para mudar status para "Entregue/Baixado"

                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _KpiCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(16),
              border: Border(left: BorderSide(color: color, width: 4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(icon, color: color, size: 20),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChartData {
  _ChartData(this.x, this.y, {this.color});
  final String x;
  final double y;
  final Color? color;
}
