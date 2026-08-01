class MecanicoModel {
  final int? id;
  final String nome;
  final String? especialidade;
  final String? telefone;
  final bool ativo;
  final String? email;
  final String? senha;

  MecanicoModel({
    this.id,
    required this.nome,
    this.especialidade,
    this.telefone,
    this.ativo = true,
    this.email,
    this.senha,
  });

  factory MecanicoModel.fromJson(Map<String, dynamic> json) {
    return MecanicoModel(
      id: json['id'],
      nome: json['nome'] ?? '',
      especialidade: json['especialidade'],
      telefone: json['telefone'],
      ativo: json['ativo'] ?? true,
      email: json['email'],
    );
  }

  Map<String, dynamic> toJsonCriar() {
    return {
      'nome': nome,
      'especialidade': especialidade,
      'telefone': telefone,
      'email': email,
      'senha': senha,
    };
  }

  Map<String, dynamic> toJsonAtualizar() {
    return {
      'nome': nome,
      'especialidade': especialidade,
      'telefone': telefone,
      'ativo': ativo,
    };
  }
}
