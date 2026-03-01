
import 'carro_model.dart';

class ClienteModel {
  final int? id;
  final String nome;
  final String? cpf;
  final String? email;
  final String? telefone;
  final List<CarroModel>? carros; // NOVO: Lista de carros vinculada

  ClienteModel({
    this.id,
    required this.nome,
    this.cpf,
    this.email,
    this.telefone,
    this.carros,
  });

  factory ClienteModel.fromJson(Map<String, dynamic> json) {
    return ClienteModel(
      id: json['id'],
      nome: json['nome'] ?? '',
      cpf: json['cpf'],
      email: json['email'],
      telefone: json['telefone'],
      carros: json['carros'] != null 
          ? (json['carros'] as List).map((i) => CarroModel.fromJson(i)).toList()
          : null,
    );
  }
}
