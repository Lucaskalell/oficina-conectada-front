class CarroModel {
  final int? id;
  final String placa;
  final String modelo;
  final String? marca;
  final int? ano;
  final String? cor;

  final int? clienteId;
  final String? nomeCliente;

  CarroModel({
    this.id,
    required this.placa,
    required this.modelo,
    this.marca,
    this.ano,
    this.cor,
    this.clienteId,
    this.nomeCliente,
  });

  factory CarroModel.fromJson(Map<String, dynamic> json) {
    return CarroModel(
      id: json['id'],
      placa: json['placa'] ?? '',
      modelo: json['modelo'] ?? '',
      marca: json['marca'],
      ano: json['ano'],
      cor: json['cor'],
      clienteId: json['clienteId'],
      nomeCliente: json['nomeCliente'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'placa': placa,
      'modelo': modelo,
      if (marca != null) 'marca': marca,
      'ano': ano,
      'cor': cor,
      if (clienteId != null) 'clienteId': clienteId,
    };
  }
}

class CarroStatusModel {
  final CarroModel carro;
  final String? status;

  CarroStatusModel({required this.carro, this.status});

  factory CarroStatusModel.fromJson(Map<String, dynamic> json) {
    return CarroStatusModel(carro: CarroModel.fromJson(json['carro']), status: json['status']);
  }
}
