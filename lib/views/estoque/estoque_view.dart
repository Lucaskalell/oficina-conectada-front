import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oficina_conectada_front/controllers/estoque/estoque_controller.dart';
import 'package:oficina_conectada_front/services/estoque_service.dart';
import 'package:oficina_conectada_front/views/estoque/sub_categoria_view.dart';
import 'package:oficina_conectada_front/models/estoque_resumo_model.dart';
import 'package:oficina_conectada_front/constants/colors.dart';

class EstoqueView extends StatefulWidget {
  const EstoqueView({super.key});

  @override
  State<EstoqueView> createState() => _EstoqueViewState();
}

class _EstoqueViewState extends State<EstoqueView> {
  late final EstoqueController _controller;
  String _activeView = 'categorias'; // 'categorias', 'todos', 'baixo_estoque'

  final Color _bgDark = ColorsApp.bgDark;
  final Color _cardDark = ColorsApp.cardDark;
  final Color _borderColor = ColorsApp.border;
  final Color _primaryColor = ColorsApp.primaryColor;
  final Color _infoColor = ColorsApp.blueNew;
  final Color _warningColor = ColorsApp.warningNew;

  @override
  void initState() {
    super.initState();
    _controller = EstoqueController(EstoqueService());
    _controller.add(BuscarResumoIniciado());
  }

  void _navegarParaSubCategoria(int categoriaId, String nomeCategoria) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => SubCategoriaView(
              categoriaId: categoriaId,
              categoriaNome: nomeCategoria,
            ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDark,
      body: BlocBuilder<EstoqueController, EstoqueState>(
        bloc: _controller,
        builder: (context, state) {
          if (state is ResumoLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ResumoSucesso) {
            return _buildBody(state.resumo);
          } else if (state is ResumoErro) {
            return _buildError(state.mensagem);
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildBody(EstoqueResumoModel resumo) {
    final bool isWideScreen = MediaQuery.of(context).size.width > 900;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildKpiSection(resumo, isWideScreen),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _activeView == 'categorias'
                    ? 'Categorias'
                    : _activeView == 'todos'
                    ? 'Todos os Itens Cadastrados'
                    : 'Itens com Estoque Baixo',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (_activeView != 'categorias')
                TextButton.icon(
                  onPressed: () => setState(() => _activeView = 'categorias'),
                  icon: const Icon(Icons.arrow_back, size: 16),
                  label: const Text('Voltar p/ Categorias'),
                  style: TextButton.styleFrom(foregroundColor: _primaryColor),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (_activeView == 'categorias')
            _buildGridCategorias(resumo, isWideScreen)
          else if (_activeView == 'todos')
            _buildTabelaMockada('todos')
          else if (_activeView == 'baixo_estoque')
            _buildTabelaMockada('baixo_estoque'),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Gestão de Estoque',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Controle de peças e insumos da oficina',
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),
          ],
        ),
        SizedBox(
          width: 300,
          child: TextField(
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Buscar por nome, código...',
              hintStyle: const TextStyle(color: Colors.white24),
              prefixIcon: const Icon(Icons.search, color: Colors.white24, size: 18),
              filled: true,
              fillColor: _cardDark,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: _borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: _primaryColor),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildKpiSection(EstoqueResumoModel resumo, bool isWide) {
    final widgets = [
      Expanded(
        child: _KpiCard(
          title: 'Itens Cadastrados',
          value: resumo.totalPecasCadastradas.toString(),
          icon: Icons.inventory_2_outlined,
          color: _primaryColor,
          onTap: () => setState(() => _activeView = 'todos'),
        ),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: _KpiCard(
          title: 'Peças em Estoque',
          value: '0',
          icon: Icons.archive_outlined,
          color: _infoColor,
          onTap: null,
        ),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: _KpiCard(
          title: 'Estoque Baixo',
          value: '${resumo.itensBaixoEstoque}',
          icon: Icons.warning_amber_rounded,
          color: _warningColor,
          onTap: () => setState(() => _activeView = 'baixo_estoque'),
        ),
      ),
    ];

    return isWide ? Row(children: widgets) : Column(children: widgets);
  }

  Widget _buildGridCategorias(EstoqueResumoModel resumo, bool isWideScreen) {
    if (resumo.categorias.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: _cardDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _borderColor),
        ),
        alignment: Alignment.center,
        child: const Text(
          'Nenhuma categoria encontrada.',
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    return GridView.builder(
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
    );
  }

  Widget _buildTabelaMockada(String tipo) {
    final List<Map<String, dynamic>> itens =
        tipo == 'baixo_estoque'
            ? [
              {'cod': 'FLT-001', 'nome': 'Filtro de Óleo - Mann', 'qtd': 2, 'min': 10},
              {'cod': 'COR-001', 'nome': 'Correia Dentada', 'qtd': 1, 'min': 5},
            ]
            : [
              {'cod': 'FLT-001', 'nome': 'Filtro de Óleo - Mann', 'qtd': 2, 'min': 10},
              {'cod': 'VEL-001', 'nome': 'Vela de Ignição', 'qtd': 24, 'min': 16},
            ];

    return Container(
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderColor),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itens.length,
        separatorBuilder: (_, __) => Divider(height: 1, color: _borderColor),
        itemBuilder: (context, i) {
          final item = itens[i];
          final bool isLow = (item['qtd'] as int) < (item['min'] as int);

          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _bgDark,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _borderColor),
              ),
              child: Icon(
                Icons.build_circle_outlined,
                color: isLow ? _warningColor : _primaryColor,
                size: 20,
              ),
            ),
            title: Text(
              item['nome'],
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              'Cód: ${item['cod']}',
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 12,
                fontFamily: 'monospace',
              ),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${item['qtd']} em estoque',
                  style: TextStyle(
                    color: isLow ? _warningColor : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Min: ${item['min']}',
                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 40),
          const SizedBox(height: 10),
          Text(message, style: const TextStyle(color: Colors.white)),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _cardDark,
              side: BorderSide(color: _borderColor),
            ),
            onPressed: () => _controller.add(BuscarResumoIniciado()),
            child: const Text('Tentar Novamente', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
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
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: ColorsApp.cardDark,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: ColorsApp.border),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
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

  const _CategoriaCard({
    required this.nome,
    required this.totalItens,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: ColorsApp.cardDark,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: ColorsApp.border),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.folder_outlined, size: 36, color: Colors.white54),
              const SizedBox(height: 12),
              Text(
                nome,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                '$totalItens itens',
                style: const TextStyle(color: Colors.white38, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
