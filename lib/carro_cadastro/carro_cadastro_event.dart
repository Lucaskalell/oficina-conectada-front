import 'package:oficina_conectada_front/model/carro_model.dart';

abstract class CarroEvent {}

class CarregarCarros extends CarroEvent {}

class CriarCarro extends CarroEvent {
  final CarroModel carro;

  CriarCarro(this.carro);
}

class AtualizarCarro extends CarroEvent {
  final int id;
  final CarroModel carro;

  AtualizarCarro(this.id, this.carro);
}

class DeletarCarro extends CarroEvent {
  final int carroId;

  DeletarCarro(this.carroId);
}