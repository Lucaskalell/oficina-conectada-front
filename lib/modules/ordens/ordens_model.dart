enum StatusOrdemDeServico {
  NAO_INICIADO,
  EM_ANDAMENTO,
  AGUARDANDO_PECA,
  AGUARDANDO_RETIRADA,
  FINALIZADO,
  CANCELADO,
}

class ItemServicoModel {
  final int? id;
  final String descricao;
  final double quantidade;
  final double valorUnitario;
  final double valorTotal;

  ItemServicoModel({
    this.id,
    required this.descricao,
    required this.quantidade,
    required this.valorUnitario,
    required this.valorTotal,
  });

  factory ItemServicoModel.fromJson(Map<String, dynamic> json) {
    return ItemServicoModel(
      id: json['id'],
      descricao: json['descricao'] ?? '',
      quantidade: (json['quantidade'] ?? 0.0).toDouble(),
      valorUnitario: (json['valorUnitario'] ?? 0.0).toDouble(),
      valorTotal: (json['valorTotal'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'descricao': descricao,
        'quantidade': quantidade,
        'valorUnitario': valorUnitario,
        'valorTotal': valorTotal,
      };
}

class OrdemDeServicoModel {
  final int? id;
  final int? clienteId;
  final int? carroId;
  final StatusOrdemDeServico status;
  final String? placa;
  final String? cliente;
  final String? carro;
  final DateTime? entrada;
  final String? defeito;
  final String? descricaoServico;
  final double? valorTotal;
  final List<ItemServicoModel>? itens;
  final String? mecanicoResponsavel;
  final String? prioridade;

  OrdemDeServicoModel({
    this.id,
    this.clienteId,
    this.carroId,
    this.status = StatusOrdemDeServico.EM_ANDAMENTO,
    this.placa,
    this.cliente,
    this.carro,
    this.entrada,
    this.defeito,
    this.descricaoServico,
    this.valorTotal,
    this.itens,
    this.mecanicoResponsavel,
    this.prioridade,
  });

  factory OrdemDeServicoModel.fromJson(Map<String, dynamic> json) {
    return OrdemDeServicoModel(
      id: json['id'],
      clienteId: json['clienteId'],
      carroId: json['carroId'],
      defeito: json['defeito'] ?? '',
      descricaoServico: json['descricaoServico'] ?? '',
      valorTotal: (json['valorTotal'] ?? 0.0).toDouble(),
      placa: json['placa'] ?? '',
      cliente: json['cliente'] ?? '',
      carro: json['carro'] ?? '',
      entrada: json['entrada'] != null ? DateTime.parse(json['entrada']) : null,
      status: StatusOrdemDeServico.values.firstWhere(
        (s) => s.name == (json['status'] ?? ''),
        orElse: () => StatusOrdemDeServico.EM_ANDAMENTO,
      ),
      itens: json['itens'] != null
          ? (json['itens'] as List).map((i) => ItemServicoModel.fromJson(i)).toList()
          : [],
      mecanicoResponsavel: json['mecanicoResponsavel'] ?? json['mecanico'] ?? '',
      prioridade: json['prioridade'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'clienteId': clienteId,
        'carroId': carroId,
        'status': status.name,
        'defeito': defeito,
        'descricaoServico': descricaoServico,
        'valorTotal': valorTotal,
        'itens': itens?.map((i) => i.toJson()).toList(),
        'mecanicoResponsavel': mecanicoResponsavel,
        'prioridade': prioridade,
      };
}
