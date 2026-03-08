class ClienteCarroRequestModel {
  final String nome;
  final String? cpf;
  final String? telefone;
  final String? email;

  //seção opcional caso queira add carro no cadstro cliente (nao cria o.s somente cadastros de cliente)!!!
  final String? placa;
  final String? modelo;
  final String? marca;
  final String? cor;
  final String? ano;

  ClienteCarroRequestModel({
    required this.nome,
    this.cpf,
    this.telefone,
    this.email,
    this.placa,
    this.modelo,
    this.marca,
    this.cor,
    this.ano,
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
      'cor': cor,
      'ano': ano,
    };
  }
}
