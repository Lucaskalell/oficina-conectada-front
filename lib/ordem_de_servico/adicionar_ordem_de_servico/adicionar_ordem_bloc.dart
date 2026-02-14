
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../ordem_de_servico_repository.dart';
import 'adicionar_ordem_event.dart';
import 'adicionar_ordem_state.dart';

class AdicionarOrdemDeServicoBloc extends Bloc<AdicionarOrdemEvent, AdicionarOrdemState> {
  final OrdemDeServicoRepository repository;

  AdicionarOrdemDeServicoBloc(this.repository) : super(AdicionarOrdemInitialState()) {
    on<CriarOrdemDeServico>((event, emit) async {
      try{
        final criarOrdemDeServico = await repository.putOrdenDeServico(event.criarOrdemDeServico);
        emit(AdicionarOrdemSuccessState(criarOrdemDeServico));
      }catch(e,s){
        emit(AdicionarOrdemErrorState(toString()));
        debugPrintStack(stackTrace: s);
      }
    });
  }
}
