// ========= IMPORTS =========

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oficina_conectada_front/estoque/estoque_bloc.dart';
import 'package:oficina_conectada_front/estoque/estoque_repository.dart';
import 'package:oficina_conectada_front/estoque/sub_categoria/sub_categoria_page.dart';

import 'model/estoque_resumo.dart';

class EstoquePage extends StatefulWidget {
  const EstoquePage({super.key});

  @override
  State<EstoquePage> createState() => _EstoquePageState();
}

class _EstoquePageState extends State<EstoquePage> {
  late final EstoqueBloc _estoqueBloc;

  @override
  void initState() {
    super.initState();
    _estoqueBloc = EstoqueBloc(EstoqueRepository());
    _estoqueBloc.add(BuscarResumoIniciado());
  }

  void _navegarParaSubCategoria(int categoriaId, String nomeCategoria) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubCategoriaPage(
          categoriaId: categoriaId,
          categoriaNome: nomeCategoria,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BlocBuilder<EstoqueBloc, EstoqueState>(
        bloc: _estoqueBloc,
        builder: (context, state) {
          if (state is ResumoLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ResumoSucesso) {
            return _buildBody(state.resumo);
          } else if (state is ResumoErro) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 40),
                  const SizedBox(height: 10),
                  Text(state.mensagem, style: const TextStyle(color: Colors.white)),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => _estoqueBloc.add(BuscarResumoIniciado()),
                    child: const Text('Tentar Novamente'),
                  )
                ],
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildBody(EstoqueResumo resumo) {
    final bool isWideScreen = MediaQuery.of(context).size.width > 900;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Gestão de Estoque',
            style: TextStyle(
                color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          _buildKpiSection(resumo, isWideScreen),

          const SizedBox(height: 32),

          const Text(
            'Categorias',
            style: TextStyle(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),

          if (resumo.categorias.isEmpty)
            const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('Nenhuma categoria', style: TextStyle(color: Colors.grey))))
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isWideScreen ? 4 : 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.6,
              ),
              itemCount: resumo.categorias.length,
              itemBuilder: (context, index) {
                final cat = resumo.categorias[index];
                return _CategoriaCard(
                  nome: cat.nome,
                  totalItens: cat.totalItens,
                  onTap: () => _navegarParaSubCategoria(cat.id, cat.nome),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildKpiSection(EstoqueResumo resumo, bool isWide) {
    final card1 = _KpiCard(
      title: 'Peças Cadastradas',
      value: resumo.totalPecasCadastradas.toString(),
      icon: Icons.inventory_2,
      color: Colors.blueAccent,
    );

    final card2 = _KpiCard(
      title: 'Item Mais Vendido',
      value: resumo.itemMaisVendido,
      icon: Icons.trending_up,
      color: Colors.greenAccent,
    );

    final card3 = _KpiCard(
      title: 'Estoque Baixo',
      value: '${resumo.itensBaixoEstoque} Itens',
      icon: Icons.warning_amber,
      color: Colors.redAccent,
    );

    if (isWide) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(child: card1),
          const SizedBox(width: 16),
          Expanded(child: card2),
          const SizedBox(width: 16),
          Expanded(child: card3),
        ],
      );
    }
    else {
      return Column(
        children: [
          card1,
          const SizedBox(height: 10),
          card2,
          const SizedBox(height: 10),
          card3,
        ],
      );
    }
  }

  @override
  void dispose() {
    _estoqueBloc.close();
    super.dispose();
  }
}


class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _KpiCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {

    return Material(
      color: const Color(0xFF1E1E1E),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title.toUpperCase(),
                      style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                  Icon(icon, color: color, size: 24),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoriaCard extends StatelessWidget {
  final String nome;
  final int totalItens;
  final VoidCallback onTap;

  const _CategoriaCard({required this.nome, required this.totalItens, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF1E1E1E),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        hoverColor: Colors.white.withOpacity(0.05),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withOpacity(0.1)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.folder_open, size: 40, color: Colors.blueGrey),
              const SizedBox(height: 12),
              Text(
                nome,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                '$totalItens itens',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}