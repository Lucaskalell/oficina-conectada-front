import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:oficina_conectada_front/services/produto_service.dart';
import 'package:oficina_conectada_front/models/produto_model.dart';

part 'produto_event.dart';
part 'produto_state.dart';

class ProdutoController extends Bloc<ProdutoEvent, ProdutoState> {
  final ProdutoService _service;

  ProdutoController(this._service) : super(ProdutoInitial()) {
    on<BuscarProdutos>((event, emit) async {
      emit(ProdutoLoading());
      try {
        final lista = await _service.buscarProdutos(event.subCategoriaId);
        emit(ProdutoSuccess(lista));
      } catch (e) {
        emit(ProdutoError(e.toString()));
      }
    });

    on<AdicionarProduto>((event, emit) async {
      emit(ProdutoLoading());
      try {
        await _service.criarProduto(event.produto, event.subCategoriaId);
        final listaAtualizada = await _service.buscarProdutos(event.subCategoriaId);
        emit(ProdutoSuccess(listaAtualizada));
      } catch (e, stackTrace) {
        debugPrint('Erro ao adicionar produto: $e\n$stackTrace');
        emit(ProdutoError('Erro ao adicionar produto: $e'));
      }
    });

    on<AtualizarProduto>((event, emit) async {
      emit(ProdutoLoading());
      try {
        await _service.atualizarProduto(event.produto, event.subCategoriaId);
        add(BuscarProdutos(event.subCategoriaId));
      } catch (e, stackTrace) {
        debugPrint('Erro ao atualizar produto: $e\n$stackTrace');
        emit(ProdutoError('Erro ao atualizar produto: $e'));
      }
    });

    on<DeletarProduto>((event, emit) async {
      emit(ProdutoLoading());
      try {
        await _service.deletarProduto(event.produtoId, event.subCategoriaId);
        add(BuscarProdutos(event.subCategoriaId));
      } catch (e, stackTrace) {
        debugPrint('Erro ao deletar produto: $e\n$stackTrace');
        emit(ProdutoError('Erro ao deletar produto: $e'));
      }
    });
  }
}
