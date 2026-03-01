
import 'package:oficina_conectada_front/enum/enum_ordem_de_servico.dart';
import 'item_servico_model.dart';
import 'foto_ordem_de_servico_model.dart';

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
  final double? valorSubtotalPecas;
  final List<ItemServicoModel>? itens;
  final List<FotoOrdemDeServicoModel>? fotos;

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
    this.valorSubtotalPecas,
    this.itens,
    this.fotos,
  });

  factory OrdemDeServicoModel.fromJson(Map<String, dynamic> json) {
    return OrdemDeServicoModel(
      id: json['id'],
      clienteId: json['clienteId'],
      carroId: json['carroId'],
      defeito: json['defeito'] ?? '',
      descricaoServico: json['descricaoServico'] ?? '',
      valorTotal: (json['valorTotal'] ?? 0.0).toDouble(),
      valorSubtotalPecas: (json['valorSubtotalPecas'] ?? 0.0).toDouble(),
      placa: json['placa'] ?? '',
      cliente: json['cliente'] ?? '',
      carro: json['carro'] ?? '',
      entrada: json['entrada'] != null ? DateTime.parse(json['entrada']) : null,
      status: StatusOrdemDeServico.values.firstWhere(
            (status) => status.name == (json['status'] ?? ''),
        orElse: () => StatusOrdemDeServico.EM_ANDAMENTO,
      ),
      itens: json['itens'] != null 
          ? (json['itens'] as List).map((i) => ItemServicoModel.fromJson(i)).toList()
          : [],
      fotos: json['fotos'] != null 
          ? (json['fotos'] as List).map((i) => FotoOrdemDeServicoModel.fromJson(i)).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clienteId': clienteId,
      'carroId': carroId,
      'status': status.name,
      'defeito': defeito,
      'descricaoServico': descricaoServico,
      'valorTotal': valorTotal,
      'valorSubtotalPecas': valorSubtotalPecas,
      'itens': itens?.map((i) => i.toJson()).toList(),
      'fotos': fotos?.map((i) => i.toJson()).toList(),
    };
  }
}
