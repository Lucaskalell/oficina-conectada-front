class VendaSemana {
  final String dia;
  final double valor;

  VendaSemana({required this.dia, required this.valor});

  factory VendaSemana.fromJson(Map<String, dynamic> json) {
    return VendaSemana(
      dia: json['dias'] ?? '',
      valor: (json['valor'] as num?)?.toDouble() ?? 0.0,
    );
  }
}