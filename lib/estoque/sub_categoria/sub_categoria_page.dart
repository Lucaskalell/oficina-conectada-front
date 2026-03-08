import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oficina_conectada_front/estoque/produtos/produto_page.dart';
import 'package:oficina_conectada_front/estoque/sub_categoria/sub_categoria_bloc.dart';
import 'package:oficina_conectada_front/estoque/sub_categoria/sub_categoria_repository.dart';

class SubCategoriaPage extends StatelessWidget {
  final int categoriaId;
  final String categoriaNome;

  const SubCategoriaPage({
    super.key,
    required this.categoriaId,
    required this.categoriaNome,
  });

  // Cores Vercel
  final Color _bgDark = const Color(0xFF09090B);
  final Color _cardDark = const Color(0xFF18181B);
  final Color _borderColor = const Color(0xFF27272A);
  final Color _primaryColor = const Color(0xFF10B981);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SubCategoriaBloc(SubCategoriaRepository())
        ..add(BuscarSubCategoriasIniciado(categoriaId)),
      child: Scaffold(
        backgroundColor: _bgDark,
        appBar: AppBar(
          title: Text(categoriaNome,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600)),
          backgroundColor: _bgDark,
          iconTheme: const IconThemeData(color: Colors.white54),
          elevation: 0,
          shape: Border(bottom: BorderSide(color: _borderColor)),
        ),
        body: BlocBuilder<SubCategoriaBloc, SubCategoriaState>(
          builder: (context, state) {
            if (state is SubCategoriaLoading || state is SubCategoriaInitial) {
              return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF10B981)));
            } else if (state is SubCategoriaSucesso) {
              final subcategorias = state.subCategorias;

              if (subcategorias.isEmpty) {
                return const Center(
                  child: Text(
                    'Nenhuma subcategoria encontrada para esta categoria.',
                    style: TextStyle(color: Colors.white54),
                  ),
                );
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Subcategorias',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Selecione uma subcategoria de $categoriaNome para ver as peças.',
                      style:
                          const TextStyle(color: Colors.white54, fontSize: 14),
                    ),
                    const SizedBox(height: 24),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 300,
                        mainAxisExtent: 90,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: subcategorias.length,
                      itemBuilder: (context, index) {
                        final sub = subcategorias[index];
                        return InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProdutoPage(
                                  subCategoriaId: sub.id,
                                  subCategoriaNome: sub.nome,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: _cardDark,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: _borderColor),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: _bgDark,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: _borderColor),
                                  ),
                                  child: Icon(Icons.category_outlined,
                                      color: _primaryColor, size: 20),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(sub.nome,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600)),
                                      const SizedBox(height: 4),
                                      const Text('Ver produtos',
                                          style: TextStyle(
                                              color: Colors.white54,
                                              fontSize: 12)),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.chevron_right,
                                    color: Colors.white24, size: 20),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            } else if (state is SubCategoriaErro) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        color: Colors.redAccent, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      'Erro ao carregar subcategorias',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.mensagem,
                      style: TextStyle(color: Colors.white54, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        context
                            .read<SubCategoriaBloc>()
                            .add(BuscarSubCategoriasIniciado(categoriaId));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Tentar Novamente'),
                    ),
                  ],
                ),
              );
            }
            return Container();
          },
        ),
      ),
    );
  }
}
