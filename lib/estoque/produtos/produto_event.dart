part of 'produto_bloc.dart';


abstract class ProdutoEvent extends Equatable{
  const ProdutoEvent();

  @override
  List<Object> get props => [];
}

class BuscarProdutos extends ProdutoEvent{
  final int subCategoriaId;
  const BuscarProdutos(this.subCategoriaId);

  @override
  List<Object> get props => [subCategoriaId];
}



class AdicionarProduto extends ProdutoEvent{
  final Produto produto;
  final int subCategoriaId;
  const AdicionarProduto(this.produto, this.subCategoriaId);
  @override
  List<Object> get props => [produto, subCategoriaId];
}
