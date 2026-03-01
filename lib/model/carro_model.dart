
class CarroModel {
  final int? id;
  final String placa;
  final String modelo;
  final String? marca;
  final int? ano;
  final String? cor;

  CarroModel({
    this.id,
    required this.placa,
    required this.modelo,
    this.marca,
    this.ano,
    this.cor,
  });

  factory CarroModel.fromJson(Map<String, dynamic> json) {
    return CarroModel(
      id: json['id'],
      placa: json['placa'] ?? '',
      modelo: json['modelo'] ?? '',
      marca: json['marca'],
      ano: json['ano'],
      cor: json['cor'],
    );
  }
}
