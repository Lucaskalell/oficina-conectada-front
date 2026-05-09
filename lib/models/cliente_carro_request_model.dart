import 'package:equatable/equatable.dart';

class ClienteCarroRequestModel extends Equatable {
  final String nome;
  final String? cpf;
  final String? telefone;
  final String? email;
  final String placa;
  final String modelo;
  final String? marca;
  final String? ano;
  final String? cor;

  const ClienteCarroRequestModel({
    required this.nome,
    this.cpf,
    this.telefone,
    this.email,
    required this.placa,
    required this.modelo,
    this.marca,
    this.ano,
    this.cor,
  });

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'cpf': cpf,
      'telefone': telefone,
      'email': email,
      'placa': placa,
      'modelo': modelo,
      'marca': marca,
      'ano': ano,
      'cor': cor,
    };
  }

  @override
  List<Object?> get props => [
    nome,
    cpf,
    telefone,
    email,
    placa,
    modelo,
    marca,
    ano,
    cor,
  ];
}
