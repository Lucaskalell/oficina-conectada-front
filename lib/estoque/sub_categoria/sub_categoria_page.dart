import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oficina_conectada_front/estoque/produtos/produto_page.dart';
import 'package:oficina_conectada_front/estoque/sub_categoria/sub_categoria_bloc.dart';
import 'package:oficina_conectada_front/estoque/sub_categoria/sub_categoria_repository.dart';

import '../../model/model_ordem_produto/sub_categoria.dart';


class SubCategoriaPage extends StatefulWidget {
  final int categoriaId;
  final String categoriaNome;
  const SubCategoriaPage({super.key, required this.categoriaId, required this.categoriaNome});

  @override
  _SubCategoriaPageState createState() => _SubCategoriaPageState();
}

class _SubCategoriaPageState extends State<SubCategoriaPage> {
  late SubCategoriaBloc _subCategoriaBloc;

  @override
  void initState() {
    super.initState();
    _subCategoriaBloc = SubCategoriaBloc(SubCategoriaRepository());
    _subCategoriaBloc.add(BuscarSubCategoriasIniciado(widget.categoriaId));
  }

  Widget _buildBody(List<SubCategoria> subCategorias) {
    if (subCategorias.isEmpty) {
      return Center(
        child: Text('Nenhuma subcategoria encontrada', style: TextStyle(color: Colors.black45, fontSize: 18)),
      );
    }
    return ListView.builder(
      itemCount: subCategorias.length,
      itemBuilder: (context, index) {
        final subCategoria = subCategorias[index];
        return ListTile(
          leading: const Icon(Icons.label_important_outline, color: Colors.blueAccent),
          title: Text(subCategoria.nome, style: TextStyle(color: Colors.white, fontSize: 18)),
          trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProdutoPage(
                  subCategoriaId: subCategoria.id,
                  subCategoriaNome: subCategoria.nome,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _blocBuilder() {
    return BlocBuilder<SubCategoriaBloc, SubCategoriaState>(
      bloc: _subCategoriaBloc,
      builder: (context, state) {
        if (state is SubCategoriaLoading || state is SubCategoriaInitial) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is SubCategoriaSucesso) {
          return _buildBody(state.subCategorias);
        }
        if (state is SubCategoriaErro) {
          return Center(
            child: Text(
              'Erro ao carregar subcategorias: ${state.mensagem}',
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
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(title: Text(widget.categoriaNome), backgroundColor: Colors.grey.shade900),
      body: Container(padding: const EdgeInsets.all(16.0), child: _blocBuilder()),
    );
  }

  @override
  void dispose() {
    _subCategoriaBloc.close();
    super.dispose();
  }
}
