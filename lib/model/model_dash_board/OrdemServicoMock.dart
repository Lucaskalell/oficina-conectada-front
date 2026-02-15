enum StatusOS { emEspera, emAndamento, concluido }

class OrdemServicoMock {
  final int id;
  final String cliente;
  final String carro;
  final String placa;
  final String servicos;
  final double valorPecas;
  final double valorMaoDeObra;
  final StatusOS status;

  double get total => valorPecas + valorMaoDeObra;

  OrdemServicoMock({
    required this.id,
    required this.cliente,
    required this.carro,
    required this.placa,
    required this.servicos,
    required this.valorPecas,
    required this.valorMaoDeObra,
    required this.status,
  });
}