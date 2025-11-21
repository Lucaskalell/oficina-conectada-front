import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oficina_conectada_front/estoque/estoque_bloc.dart';
import 'package:oficina_conectada_front/estoque/estoque_repository.dart';
import 'package:oficina_conectada_front/estoque/sub_categoria/sub_categoria_page.dart';

import 'model/categoria.dart';

class EstoquePage extends StatefulWidget {
  const EstoquePage({super.key});

  @override
  _EstoquePageState createState() => _EstoquePageState();
}

class _EstoquePageState extends State<EstoquePage> {
  late EstoqueBloc _estoqueBloc;
  @override
  void initState() {
    super.initState();
    _estoqueBloc = EstoqueBloc(EstoqueRepository());
    _estoqueBloc.add(BuscarCategoriasIniciado());
  }

  Widget _buildBody(List<Categoria> categorias) {
    if (categorias.isEmpty) {
      return const Center(
        child: Text(
          'Nenhuma categoria encontrada no banco de dados.',
          style: TextStyle(color: Colors.grey, fontSize: 18),
        ),
      );
    }

    return ListView.builder(
      itemCount: categorias.length,
      itemBuilder: (context, index) {
        final categoria = categorias[index];
        return ListTile(
          leading: const Icon(
            Icons.category_rounded,
            color: Colors.blueAccent,
          ),
          title: Text(
            categoria.nome,
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            size: 14,
            color: Colors.grey,
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:(context)=>SubCategoriaPage(
                  categoriaId: categoria.id,
                  categoriaNome: categoria.nome,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _blocBuilder() {
    return BlocBuilder<EstoqueBloc, EstoqueState>(
      bloc: _estoqueBloc,
      builder: (context, state) {
        if (state is EstoqueLoading || state is EstoqueInitial) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is EstoqueSucesso) {
          return _buildBody(state.categorias);
        }
        if (state is EstoqueErro) {
          return Center(
            child: Text(
              'Erro ao carregar o estoque: ${state.mensagem}',
              style: const TextStyle(color: Colors.redAccent),
            ),
          );
        }
        return const Center(child: Text('Estado desconhecido.'));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF121212),
      padding: const EdgeInsets.all(16.0),
      child: _blocBuilder(),
    );
  }

  @override
  void dispose() {
    _estoqueBloc.close();
    super.dispose();
  }
}
