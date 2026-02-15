
import 'package:oficina_conectada_front/enum/enum_ordem_de_servico.dart';

class OrdemDeServicoModel {
  final int? id;
  final int? clienteId; // NOVO
  final int? carroId;    // NOVO
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
  });

  factory OrdemDeServicoModel.fromJson(Map<String, dynamic> json) {
    return OrdemDeServicoModel(
      id: json['id'],
      defeito: json['defeito'] ?? '',
      descricaoServico: json['descricaoServico'] ?? '',
      valorTotal: (json['valorTotal'] ?? 0).toDouble(),
      placa: json['placa'] ?? '',
      cliente: json['cliente'] ?? '', // O DTO de resposta do Java envia o nome aqui
      carro: json['carro'] ?? '',     // O DTO de resposta do Java envia o modelo aqui
      entrada: json['entrada'] != null ? DateTime.parse(json['entrada']) : null,
      status: StatusOrdemDeServico.values.firstWhere(
            (status) => status.name == (json['status'] ?? ''),
        orElse: () => StatusOrdemDeServico.EM_ANDAMENTO,
      ),
    );
  }

  // Este método deve gerar o JSON que o CriarOrdemDeServicoRequest do Java espera
  Map<String, dynamic> toJson() {
    return {
      'clienteId': clienteId,
      'carroId': carroId,
      'defeito': defeito,
      'descricaoServico': descricaoServico,
      'valorTotal': valorTotal,
    };
  }
}
