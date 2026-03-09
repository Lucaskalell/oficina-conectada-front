class DashboardModel {
  final double faturamentoMensal;
  final int osAbertas;
  final int osConcluidas;
  final int veiculosEmServico;
  final List<FaturamentoMensalModel> graficoFaturamento;
  final List<ServicosMensalModel> graficoServicos;
  final List<OrdemRecenteModel> ordensRecentes;
  final List<EstoqueBaixoModel> estoqueBaixo;
  final List<AgendamentoModel> agendamentos;

  DashboardModel({
    required this.faturamentoMensal,
    required this.osAbertas,
    required this.osConcluidas,
    required this.veiculosEmServico,
    required this.graficoFaturamento,
    required this.graficoServicos,
    required this.ordensRecentes,
    required this.estoqueBaixo,
    required this.agendamentos,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      faturamentoMensal: (json['faturamentoMensal'] ?? 0.0).toDouble(),
      osAbertas: json['osAbertas'] ?? 0,
      osConcluidas: json['osConcluidas'] ?? 0,
      veiculosEmServico: json['veiculosEmServico'] ?? 0,

      graficoFaturamento:
          (json['graficoFaturamento'] as List<dynamic>?)
              ?.map((e) => FaturamentoMensalModel.fromJson(e))
              .toList() ??
          [],

      graficoServicos:
          (json['graficoServicos'] as List<dynamic>?)
              ?.map((e) => ServicosMensalModel.fromJson(e))
              .toList() ??
          [],

      ordensRecentes:
          (json['ordensRecentes'] as List<dynamic>?)
              ?.map((e) => OrdemRecenteModel.fromJson(e))
              .toList() ??
          [],

      estoqueBaixo:
          (json['estoqueBaixo'] as List<dynamic>?)
              ?.map((e) => EstoqueBaixoModel.fromJson(e))
              .toList() ??
          [],

      agendamentos:
          (json['agendaHoje'] as List<dynamic>?)
              ?.map((e) => AgendamentoModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}


// SUB-MODELS

class FaturamentoMensalModel {
  final String mes;
  final double receita;
  final double despesa;

  FaturamentoMensalModel({required this.mes, required this.receita, required this.despesa});

  factory FaturamentoMensalModel.fromJson(Map<String, dynamic> json) {
    return FaturamentoMensalModel(
      mes: json['mes'] ?? '',
      receita: (json['receita'] ?? 0.0).toDouble(),
      despesa: (json['despesa'] ?? 0.0).toDouble(),
    );
  }
}

class ServicosMensalModel {
  final String mes;
  final int totalOs;

  ServicosMensalModel({required this.mes, required this.totalOs});

  factory ServicosMensalModel.fromJson(Map<String, dynamic> json) {
    return ServicosMensalModel(mes: json['mes'] ?? '', totalOs: json['totalOs'] ?? 0);
  }
}

class OrdemRecenteModel {
  final String codigoOs;
  final String servico;
  final String clienteCarro;
  final String tempo;
  final String status;

  OrdemRecenteModel({
    required this.codigoOs,
    required this.servico,
    required this.clienteCarro,
    required this.tempo,
    required this.status,
  });

  factory OrdemRecenteModel.fromJson(Map<String, dynamic> json) {
    return OrdemRecenteModel(
      codigoOs: json['codigoOs'] ?? '',
      servico: json['servico'] ?? '',
      clienteCarro: json['clienteCarro'] ?? '',
      tempo: json['tempo'] ?? '',
      status: json['status'] ?? '',
    );
  }
}

class EstoqueBaixoModel {
  final String nomePeca;
  final int quantidadeAtual;
  final int quantidadeMinima;

  EstoqueBaixoModel({
    required this.nomePeca,
    required this.quantidadeAtual,
    required this.quantidadeMinima,
  });

  factory EstoqueBaixoModel.fromJson(Map<String, dynamic> json) {
    return EstoqueBaixoModel(
      nomePeca: json['nomePeca'] ?? '',
      quantidadeAtual: json['quantidadeAtual'] ?? 0,
      quantidadeMinima: json['quantidadeMinima'] ?? 0,
    );
  }
}

class AgendamentoModel {
  final String horario;
  final String servico;
  final String clienteCarro;
  final String mecanico;
  final String status;

  AgendamentoModel({
    required this.horario,
    required this.servico,
    required this.clienteCarro,
    required this.mecanico,
    required this.status,
  });

  factory AgendamentoModel.fromJson(Map<String, dynamic> json) {
    return AgendamentoModel(
      horario: json['horario'] ?? '',
      servico: json['servico'] ?? '',
      clienteCarro: json['clienteCarro'] ?? '',
      mecanico: json['mecanico'] ?? '',
      status: json['status'] ?? '',
    );
  }
}
