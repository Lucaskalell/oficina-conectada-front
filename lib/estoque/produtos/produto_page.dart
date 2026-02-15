import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oficina_conectada_front/estoque/produtos/produto_bloc.dart';
import 'package:oficina_conectada_front/estoque/produtos/produto_repository.dart';


import '../../components/toast/custom_toast.dart';
import '../../model/model_ordem_produto/produto.dart';

class ProdutoPage extends StatefulWidget {
  final int subCategoriaId;
  final String subCategoriaNome;

  const ProdutoPage({super.key, required this.subCategoriaId, required this.subCategoriaNome});

  @override
  State<ProdutoPage> createState() => _ProdutoPageState();
}

class _ProdutoPageState extends State<ProdutoPage> {
  late ProdutoBloc _bloc;

  final _nomeController = TextEditingController();
  final _precoCustoController = TextEditingController();
  final _precoVendaController = TextEditingController();
  final _quantidadeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _bloc = ProdutoBloc(ProdutoRepository());
    _bloc.add(BuscarProdutos(widget.subCategoriaId));
  }

  _mostrarModal({Produto? produtoParaEditar}) {
    final isEdicao = produtoParaEditar != null;
    if (isEdicao) {
      _nomeController.text = produtoParaEditar.nome;
      _quantidadeController.text = produtoParaEditar.quantidadeEmEstoque.toString();
      _precoCustoController.text = produtoParaEditar.precoCusto.toString();
      _precoVendaController.text = produtoParaEditar.precoVenda.toString();
    } else {
      _nomeController.clear();
      _quantidadeController.clear();
      _precoCustoController.clear();
      _precoVendaController.clear();
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey.shade900,
          title: Text(
            isEdicao ? 'Editar Produto' : 'Adicionar Novo Produto',
            style: const TextStyle(color: Colors.white),
          ),

          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nomeController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Nome',
                    labelStyle: TextStyle(color: Colors.grey),
                  ),
                ),
                TextField(
                  controller: _quantidadeController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Qtd',
                    labelStyle: TextStyle(color: Colors.grey),
                  ),
                ),
                TextField(
                  controller: _precoCustoController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Custo',
                    labelStyle: TextStyle(color: Colors.grey),
                  ),
                ),
                TextField(
                  controller: _precoVendaController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Venda',
                    labelStyle: TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar', style: TextStyle(color: Colors.redAccent)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
              onPressed: () {
                final produtoMontado = Produto(
                  id: isEdicao ? produtoParaEditar.id : 0,
                  nome: _nomeController.text,
                  quantidadeEmEstoque: int.tryParse(_quantidadeController.text) ?? 0,
                  precoCusto: double.tryParse(_precoCustoController.text) ?? 0.0,
                  precoVenda: double.tryParse(_precoVendaController.text) ?? 0.0,
                  descricao: null,
                );
                if (isEdicao) {
                  _bloc.add(AtualizarProduto(produtoMontado, widget.subCategoriaId));
                } else {
                  _bloc.add(AdicionarProduto(produtoMontado, widget.subCategoriaId));
                }
                Navigator.pop(context);
              },
              child: Text(
                isEdicao ? 'Atualizar' : 'Salvar',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text(widget.subCategoriaNome),
        backgroundColor: Colors.grey.shade900,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {_mostrarModal()},
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add_circle, color: Colors.white),
      ),
      body: BlocConsumer<ProdutoBloc, ProdutoState>(
        bloc: _bloc,
        listener: (context, state) {
          if (state is ProdutoError) {
            CustomToast.show(context, message: state.message, type: ToastType.error);
          }
        },
        builder: (context, state) {
          if (state is ProdutoLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ProdutoSuccess) {
            return _buildList(state.produtos);
          } else if (state is ProdutoError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 60, color: Colors.grey.shade700),
                  const SizedBox(height: 10),
                  const Text(
                    'Não foi possível carregar os dados.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildList(List<Produto> lista) {
    if (lista.isEmpty) {
      return const Center(
        child: Text('Nenhum produto encontrado.', style: TextStyle(color: Colors.grey)),
      );
    }
    return ListView.builder(
      itemCount: lista.length,
      itemBuilder: (context, index) {
        final prod = lista[index];

        return Card(
          color: Colors.grey.shade900,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: const Icon(Icons.build_circle_outlined, color: Colors.orangeAccent),
            title: Text(
              prod.nome,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Estoque: ${prod.quantidadeEmEstoque} | Preço: R\$ ${prod.precoVenda.toStringAsFixed(2)}',
              style: TextStyle(color: Colors.grey.shade400),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blueAccent),
                  tooltip: 'Editar',
                  onPressed: () {
                    _mostrarModal(produtoParaEditar: prod);
                  },
                ),

                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  tooltip: 'Excluir',
                  onPressed: () {
                    _confirmarExclusao(prod.id, prod.nome);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmarExclusao(int produtoId, String nomeProduto) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey.shade900,
          title: const Text('Excluir Produto', style: TextStyle(color: Colors.white)),
          content: Text(
            'Tem certeza que deseja excluir "$nomeProduto"?',
            style: const TextStyle(color: Colors.grey),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              onPressed: () {
                _bloc.add(DeletarProduto(produtoId, widget.subCategoriaId));
                Navigator.pop(context);
              },
              child: const Text('Excluir', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _bloc.close();
    _nomeController.dispose();
    _precoCustoController.dispose();
    _precoVendaController.dispose();
    _quantidadeController.dispose();
    super.dispose();
  }
}
