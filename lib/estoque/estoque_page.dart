import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oficina_conectada_front/estoque/estoque_bloc.dart';
import 'package:oficina_conectada_front/estoque/estoque_repository.dart';
import 'package:oficina_conectada_front/estoque/sub_categoria/sub_categoria_page.dart';
import '../model/model_ordem_produto/estoque_resumo.dart';

class EstoquePage extends StatefulWidget {
  const EstoquePage({super.key});

  @override
  State<EstoquePage> createState() => _EstoquePageState();
}

class _EstoquePageState extends State<EstoquePage> {
  late final EstoqueBloc _estoqueBloc;
  String _activeView = 'categorias'; // 'categorias', 'todos', 'baixo_estoque'

  // Cores
  final Color _bgDark = const Color(0xFF09090B);
  final Color _cardDark = const Color(0xFF18181B);
  final Color _borderColor = Colors.white.withOpacity(0.1);
  final Color _primaryColor = const Color(0xFF10B981);
  final Color _infoColor = const Color(0xFF60A5FA);
  final Color _warningColor = const Color(0xFFF59E0B);

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
        builder: (context) => SubCategoriaPage(categoriaId: categoriaId, categoriaNome: nomeCategoria),
      ),
    );
  }

  @override
  void dispose() {
    _estoqueBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDark,
      body: BlocBuilder<EstoqueBloc, EstoqueState>(
        bloc: _estoqueBloc,
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

  Widget _buildBody(EstoqueResumo resumo) {
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

          // Título dinâmico baseado no clique + Botão de Voltar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _activeView == 'categorias' ? 'Categorias' :
                _activeView == 'todos' ? 'Todos os Itens Cadastrados' : 'Itens com Estoque Baixo',
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
              ),
              if (_activeView != 'categorias')
                TextButton.icon(
                  onPressed: () => setState(() => _activeView = 'categorias'),
                  icon: const Icon(Icons.arrow_back, size: 16),
                  label: const Text('Voltar p/ Categorias'),
                  style: TextButton.styleFrom(foregroundColor: _primaryColor),
                )
            ],
          ),
          const SizedBox(height: 16),

          // Renderização Condicional
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
            Text('Gestão de Estoque', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text('Controle de peças e insumos da oficina', style: TextStyle(color: Colors.white54, fontSize: 14)),
          ],
        ),
        // Barra de Busca
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
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: _borderColor)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: _primaryColor)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildKpiSection(EstoqueResumo resumo, bool isWide) {
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
          value: '0', // Aqui entra o total de quantidade física meu backend vai passar a mandar
          icon: Icons.archive_outlined,
          color: _infoColor,
          onTap: null, // Sem ação, apenas info
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

  Widget _buildGridCategorias(EstoqueResumo resumo, bool isWideScreen) {
    if (resumo.categorias.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(color: _cardDark, borderRadius: BorderRadius.circular(12), border: Border.all(color: _borderColor)),
        alignment: Alignment.center,
        child: const Text('Nenhuma categoria encontrada.', style: TextStyle(color: Colors.white54)),
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

  // Tabela Visual (Substitua pelos dados do backend futuramente)
  Widget _buildTabelaMockada(String tipo) {
    final List<Map<String, dynamic>> itens = tipo == 'baixo_estoque'
        ? [{'cod': 'FLT-001', 'nome': 'Filtro de Óleo - Mann', 'qtd': 2, 'min': 10}, {'cod': 'COR-001', 'nome': 'Correia Dentada', 'qtd': 1, 'min': 5}]
        : [{'cod': 'FLT-001', 'nome': 'Filtro de Óleo - Mann', 'qtd': 2, 'min': 10}, {'cod': 'VEL-001', 'nome': 'Vela de Ignição', 'qtd': 24, 'min': 16}];

    return Container(
      decoration: BoxDecoration(color: _cardDark, borderRadius: BorderRadius.circular(12), border: Border.all(color: _borderColor)),
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
              decoration: BoxDecoration(color: _bgDark, borderRadius: BorderRadius.circular(8), border: Border.all(color: _borderColor)),
              child: Icon(Icons.build_circle_outlined, color: isLow ? _warningColor : _primaryColor, size: 20),
            ),
            title: Text(item['nome'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
            subtitle: Text('Cód: ${item['cod']}', style: const TextStyle(color: Colors.white54, fontSize: 12, fontFamily: 'monospace')),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${item['qtd']} em estoque', style: TextStyle(color: isLow ? _warningColor : Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                Text('Min: ${item['min']}', style: const TextStyle(color: Colors.white54, fontSize: 11)),
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
            style: ElevatedButton.styleFrom(backgroundColor: _cardDark, side: BorderSide(color: _borderColor)),
            onPressed: () => _estoqueBloc.add(BuscarResumoIniciado()),
            child: const Text('Tentar Novamente', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }
}

// ==== WIDGETS AUXILIARES ====

class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _KpiCard({required this.title, required this.value, required this.icon, required this.color, this.onTap});

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
            color: const Color(0xFF18181B),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(title, style: const TextStyle(color: Colors.white54, fontSize: 13, fontWeight: FontWeight.w500)),
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

  const _CategoriaCard({required this.nome, required this.totalItens, required this.onTap});

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
            color: const Color(0xFF18181B), // _cardDark
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.folder_outlined, size: 36, color: Colors.white54), // Ícone Vercel style
              const SizedBox(height: 12),
              Text(nome, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
              const SizedBox(height: 4),
              Text('$totalItens itens', style: const TextStyle(color: Colors.white38, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}