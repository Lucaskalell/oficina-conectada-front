
import 'package:oficina_conectada_front/enum/enum_ordem_de_servico.dart';

class OrdemDeServicoModel {
  final int? id;
  final StatusOrdemDeServico status;
  final String? placa;
  final String? cliente;
  final String? carro;
  final DateTime? entrada;
  final String? defeito;
  final String? descricaoServico;
  final double? valorTotal;

  OrdemDeServicoModel({
    this.id,
    this.status = StatusOrdemDeServico.EM_ANDAMENTO,
    this.placa,
    this.cliente,
    this.carro,
    this.entrada,
    this.defeito,
    this.descricaoServico,
    this.valorTotal,
  });

  factory OrdemDeServicoModel.fromJson(Map<String, dynamic> json) {
    return OrdemDeServicoModel(
      id: json['id'] ?? 0,
      defeito: json['defeito'] ?? '',
      descricaoServico: json['descricaoServico'] ?? '',
      valorTotal: (json['valorTotal'] ?? 0).toDouble(),
      placa: json['placa'] ?? '',
      cliente: json['cliente'] ?? '',
      carro: json['carro'] ?? '',
      entrada: json['entrada'] != null ? DateTime.parse(json['entrada']) : null,
      status: StatusOrdemDeServico.values.firstWhere(
            (status) => status.name == (json['status'] ?? ''),
        orElse: () => StatusOrdemDeServico.EM_ANDAMENTO,
      ),
    );
    }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status.name,
      'placa': placa,
      'cliente': cliente,
      'carro': carro,
      'entrada': entrada?.toIso8601String(),
      'defeito': defeito,
      'descricaoServico': descricaoServico,
      'valorTotal': valorTotal,
    };
  }
}