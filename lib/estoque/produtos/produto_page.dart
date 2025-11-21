

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oficina_conectada_front/estoque/produtos/produto_bloc.dart';
import 'package:oficina_conectada_front/estoque/produtos/produto_repository.dart';

import '../model/produto.dart';

class ProdutoPage extends StatefulWidget {
  final int subCategoriaId;
  final String subCategoriaNome;

  const ProdutoPage({
    super.key,
    required this.subCategoriaId,
    required this.subCategoriaNome,
  });

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

  void _mostrarModalAdicionar() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey.shade900,
          title: const Text('Adicionar Novo Produto', style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nomeController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Nome do Produto',
                    labelStyle: TextStyle(color: Colors.grey),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                  ),
                ),
                TextField(
                  controller: _quantidadeController,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Quantidade Inicial',
                    labelStyle: TextStyle(color: Colors.grey),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                  ),
                ),
                TextField(
                  controller: _precoCustoController,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Preço de Custo (R\$)',
                    labelStyle: TextStyle(color: Colors.grey),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                  ),
                ),
                TextField(
                  controller: _precoVendaController,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Preço de Venda (R\$)',
                    labelStyle: TextStyle(color: Colors.grey),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
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
                // TODO: Chamar o BLoC para salvar o produto!
                // (Precisamos criar o evento AdicionarProduto no BLoC primeiro)
                print("Salvando produto: ${_nomeController.text}");
                Navigator.pop(context);
              },
              child: const Text('Salvar', style: TextStyle(color: Colors.white)),
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
        onPressed: _mostrarModalAdicionar,
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add_circle, color: Colors.white),
      ),

      body: BlocBuilder<ProdutoBloc, ProdutoState>(
        bloc: _bloc,
        builder: (context, state) {
          if (state is ProdutoLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ProdutoSuccess) {
            return _buildList(state.produtos);
          } else if (state is ProdutoError) {
            return Center(child: Text("Erro: ${state.message}", style: const TextStyle(color: Colors.red)));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildList(List<Produto> lista) {
    if (lista.isEmpty) {
      return const Center(child: Text("Nenhum produto encontrado.", style: TextStyle(color: Colors.grey)));
    }
    return ListView.builder(
      itemCount: lista.length,
      itemBuilder: (context, index) {
        final prod = lista[index];
        return Card(
          color: Colors.grey.shade900,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text(prod.nome, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: Text(
              "Estoque: ${prod.quantidadeEmEstoque} | Preço: R\$ ${prod.precoVenda}",
              style: TextStyle(color: Colors.grey.shade400),
            ),
            leading: const Icon(Icons.build, color: Colors.orange),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
            onTap: () {
              // Detalhes
            },
          ),
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