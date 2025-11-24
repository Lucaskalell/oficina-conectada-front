import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:oficina_conectada_front/estoque/produtos/produto_repository.dart';

import 'package:oficina_conectada_front/estoque/model/produto.dart';

part 'produto_event.dart';
part 'produto_state.dart';

class ProdutoBloc extends Bloc<ProdutoEvent, ProdutoState> {
  final ProdutoRepository produtoRepository;

  ProdutoBloc(this.produtoRepository) : super(ProdutoInitial()) {


    on<BuscarProdutos>((event, emit) async {
      emit(ProdutoLoading());
      try {
        final lista = await produtoRepository.buscarProdutos(event.subCategoriaId);
        emit(ProdutoSuccess(lista));
      } catch (e) {
        emit(ProdutoError(e.toString()));
      }
    });

    on<AdicionarProduto>((event, emit) async {
      emit(ProdutoLoading());
      try {
        await produtoRepository.criarProduto(event.produto, event.subCategoriaId);
        final listaAtualizada = await produtoRepository.buscarProdutos(event.subCategoriaId);
        emit(ProdutoSuccess(listaAtualizada));
      } catch (e, stackTrace) {
        debugPrint('erro aqui :$e');
        debugPrint('segue o erro :$stackTrace');
        emit(ProdutoError('Erro ao adicionar produto:'));
      }
    });

    on<AtualizarProduto>((event, emit) async {
      emit(ProdutoLoading());
      try {
        await produtoRepository.atualizarProduto(event.produto, event.subCategoriaId);
        add(BuscarProdutos(event.subCategoriaId));
      } catch (e, stackTrace) {
        debugPrint('erro aqui :$e');
        debugPrint('segue o erro :$stackTrace');
        emit(ProdutoError('Erro ao atualizar produto:'));
      }
    });


    on<DeletarProduto>((event, emit)async{
      emit(ProdutoLoading());
      try{
        await produtoRepository.deletarProduto(event.produtoId, event.subCategoriaId);
        add(BuscarProdutos(event.subCategoriaId));
      }catch(e,stackTrace){
        debugPrint('deu erro :$e');
        debugPrint('erro aqui :$stackTrace');
        emit(ProdutoError('Erro ao deletar produto:$e'));
      }
    });
  }
}
