class AgendamentoModel {
  final int? id;
  final DateTime dataHora;
  final String descricaoServico;
  final String status;
  final int? clienteId;
  final String? clienteNome;
  final int? carroId;
  final String? carroModelo;
  final String? carroPlaca;
  final int? mecanicoId;
  final String? mecanicoNome;

  AgendamentoModel({
    this.id,
    required this.dataHora,
    required this.descricaoServico,
    this.status = 'AGENDADO',
    this.clienteId,
    this.clienteNome,
    this.carroId,
    this.carroModelo,
    this.carroPlaca,
    this.mecanicoId,
    this.mecanicoNome,
  });

  factory AgendamentoModel.fromJson(Map<String, dynamic> json) {
    final cliente = json['cliente'] as Map<String, dynamic>?;
    final carro = json['carro'] as Map<String, dynamic>?;
    final mecanico = json['mecanico'] as Map<String, dynamic>?;

    return AgendamentoModel(
      id: json['id'],
      dataHora: DateTime.parse(json['dataHora']),
      descricaoServico: json['descricaoServico'] ?? '',
      status: json['status'] ?? 'AGENDADO',
      clienteId: cliente?['id'],
      clienteNome: cliente?['nome'],
      carroId: carro?['id'],
      carroModelo: carro?['modelo'],
      carroPlaca: carro?['placa'],
      mecanicoId: mecanico?['id'],
      mecanicoNome: mecanico?['nome'],
    );
  }

  Map<String, dynamic> toJsonCriar() {
    return {
      'clienteId': clienteId,
      'carroId': carroId,
      'mecanicoId': mecanicoId,
      'dataHora': dataHora.toIso8601String(),
      'descricaoServico': descricaoServico,
    };
  }
}
