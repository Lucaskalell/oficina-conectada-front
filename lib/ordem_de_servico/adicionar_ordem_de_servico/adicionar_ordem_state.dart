
import 'package:oficina_conectada_front/model/cliente_model.dart';
import 'package:oficina_conectada_front/model/carro_model.dart';

abstract class AdicionarOrdemState {}

class AdicionarOrdemInitialState extends AdicionarOrdemState {}

class AdicionarOrdemLoadingState extends AdicionarOrdemState {}

// Estado que entrega a lista inicial de clientes
class ClientesCarregadosState extends AdicionarOrdemState {
  final List<ClienteModel> clientes;
  ClientesCarregadosState(this.clientes);
}

// Estado que entrega os carros do cliente selecionado
class DadosClienteCompletoCarregadosState extends AdicionarOrdemState {
  final List<CarroModel> carros;
  DadosClienteCompletoCarregadosState(this.carros);
}

class AdicionarOrdemSuccessState extends AdicionarOrdemState {}

class AdicionarOrdemErrorState extends AdicionarOrdemState {
  final String message;
  AdicionarOrdemErrorState(this.message);
}
