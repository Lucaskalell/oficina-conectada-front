import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:oficina_conectada_front/estoque/produtos/produto_repository.dart';


import '../model/produto.dart';

part 'produto_event.dart';
part 'produto_state.dart';

class ProdutoBloc extends Bloc<ProdutoEvent, ProdutoState> {
  final ProdutoRepository repository;

  ProdutoBloc(this.repository) : super(ProdutoInitial()) {
    on<BuscarProdutos>((event, emit) async {
      emit(ProdutoLoading());
      try {
        final lista = await repository.buscarProdutos(event.subCategoriaId);
        emit(ProdutoSuccess(lista));
      } catch (e) {
        emit(ProdutoError(e.toString()));
      }
    });
  }
}