
class FotoOrdemDeServicoModel {
  final int? id;
  final String caminhoFoto;
  final String? legenda;

  FotoOrdemDeServicoModel({
    this.id,
    required this.caminhoFoto,
    this.legenda,
  });

  factory FotoOrdemDeServicoModel.fromJson(Map<String, dynamic> json) {
    return FotoOrdemDeServicoModel(
      id: json['id'],
      caminhoFoto: json['caminhoFoto'] ?? '',
      legenda: json['legenda'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'caminhoFoto': caminhoFoto,
      'legenda': legenda,
    };
  }
}
