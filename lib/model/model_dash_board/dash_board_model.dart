import 'dash_board_semana.dart';

class DashboardData {
  final double faturamentoMensal;
  final int totalOrdensAbertas;
  final int produtosBaixoEstoque;
  final List<VendaSemana> vendasSemana;
  final Map<String, int> statusOrdens;

  DashboardData({
    required this.faturamentoMensal,
    required this.totalOrdensAbertas,
    required this.produtosBaixoEstoque,
    required this.vendasSemana,
    required this.statusOrdens,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      faturamentoMensal: (json['faturamentoMensal'] as num?)?.toDouble() ?? 0.0,
      totalOrdensAbertas: (json['totalOrdensAbertas'] as num?)?.toInt() ?? 0,

      produtosBaixoEstoque: (json['produtosBaixosEstoque'] as num?)?.toInt() ?? 0,

      vendasSemana: (json['vendasSemana'] as List?)
          ?.map((item) => VendaSemana.fromJson(item))
          .toList() ?? [],
      statusOrdens: Map<String, int>.from(json['statusOrdens'] ?? {}),
    );
  }
}