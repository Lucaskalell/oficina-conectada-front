import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oficina_conectada_front/core/constants/app_colors.dart';
import 'package:oficina_conectada_front/models/produto_model.dart';
import 'package:oficina_conectada_front/modules/estoque/estoque_bloc.dart';
import 'package:oficina_conectada_front/modules/estoque/estoque_event.dart';
import 'package:oficina_conectada_front/modules/estoque/estoque_service.dart';
import 'package:oficina_conectada_front/modules/estoque/estoque_state.dart';
import 'package:oficina_conectada_front/shared/widgets/custom_toast/custom_toast.dart';

class EstoquePage extends StatefulWidget {
  const EstoquePage({super.key});

  @override
  State<EstoquePage> createState() => _EstoquePageState();
}

class _EstoquePageState extends State<EstoquePage> {
  late final EstoqueBloc _bloc;
  late final TextEditingController _buscaController;
  late final TextEditingController _nomeController;
  late final TextEditingController _quantController;
  late final TextEditingController _custoController;
  late final TextEditingController _vendaController;

  @override
  void initState() {
    super.initState();
    _bloc = EstoqueBloc(EstoqueService());
    _buscaController = TextEditingController();
    _nomeController = TextEditingController();
    _quantController = TextEditingController();
    _custoController = TextEditingController();
    _vendaController = TextEditingController();
    _bloc.add(EstoqueCarregado());
  }

  @override
  void dispose() {
    _bloc.close();
    _buscaController.dispose();
    _nomeController.dispose();
    _quantController.dispose();
    _custoController.dispose();
    _vendaController.dispose();
    super.dispose();
  }

  StatusEstoque _statusProduto(ProdutoModel p) {
    if (p.quantidadeEmEstoque <= 0) return StatusEstoque.esgotado;
    if (p.quantidadeEmEstoque <= 5) return StatusEstoque.baixo;
    return StatusEstoque.emEstoque;
  }

  Color _corCategoria(int index, String nome) {
    const knownHues = {
      'suspensao': 152.0,
      'freio': 8.0,
      'motor': 212.0,
      'lubrificante': 38.0,
      'alinhamento': 276.0,
    };
    final nomeKey = _normalizar(nome);
    for (final entry in knownHues.entries) {
      if (nomeKey.contains(entry.key)) {
        return HSLColor.fromAHSL(1.0, entry.value, 0.6, 0.5).toColor();
      }
    }
    const defaultHues = [152.0, 212.0, 38.0, 276.0, 8.0, 173.0, 260.0, 45.0];
    return HSLColor.fromAHSL(1.0, defaultHues[index % defaultHues.length], 0.6, 0.5).toColor();
  }

  String _normalizar(String s) => s
      .toLowerCase()
      .replaceAll('ã', 'a')
      .replaceAll('á', 'a')
      .replaceAll('â', 'a')
      .replaceAll('à', 'a')
      .replaceAll('ç', 'c')
      .replaceAll('é', 'e')
      .replaceAll('ê', 'e')
      .replaceAll('í', 'i')
      .replaceAll('ó', 'o')
      .replaceAll('ô', 'o')
      .replaceAll('ú', 'u');

  void _confirmarDelecaoProduto(int id, String nome) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.fundoCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.borda),
        ),
        title: const Text('Excluir Peça', style: TextStyle(color: Colors.white)),
        content: Text(
          'Deseja excluir "$nome"? Essa ação não pode ser desfeita.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.erro, foregroundColor: Colors.white),
            onPressed: () {
              _bloc.add(ProdutoExcluido(id));
              Navigator.pop(ctx);
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  void _mostrarModalProduto({ProdutoModel? produto}) {
    final isEdicao = produto != null;
    if (isEdicao) {
      _nomeController.text = produto.nome;
      _quantController.text = produto.quantidadeEmEstoque.toString();
      _custoController.text = produto.precoCusto.toStringAsFixed(2);
      _vendaController.text = produto.precoVenda.toStringAsFixed(2);
    } else {
      _nomeController.clear();
      _quantController.clear();
      _custoController.clear();
      _vendaController.clear();
    }

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.fundoCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.borda),
        ),
        child: Container(
          width: 420,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    isEdicao ? Icons.edit_outlined : Icons.add_box_outlined,
                    color: AppColors.primaria,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    isEdicao ? 'Editar Peça' : 'Nova Peça',
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _construirLabel('Nome da Peça'),
              _construirCampo(_nomeController, 'Ex: Amortecedor Dianteiro'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _construirLabel('Quantidade'),
                        _construirCampo(_quantController, '0', isNumero: true),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _construirLabel('Preço Custo'),
                        _construirCampo(_custoController, '0.00', isNumero: true),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _construirLabel('Preço Venda'),
              _construirCampo(_vendaController, '0.00', isNumero: true),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaria,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      final p = ProdutoModel(
                        id: isEdicao ? produto.id : 0,
                        nome: _nomeController.text.trim(),
                        quantidadeEmEstoque: int.tryParse(_quantController.text) ?? 0,
                        precoCusto: double.tryParse(_custoController.text) ?? 0.0,
                        precoVenda: double.tryParse(_vendaController.text) ?? 0.0,
                      );
                      _bloc.add(ProdutoSalvo(p, isEdicao: isEdicao));
                      Navigator.pop(ctx);
                    },
                    child: Text(isEdicao ? 'Atualizar' : 'Cadastrar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fundoPrincipal,
      body: BlocConsumer<EstoqueBloc, EstoqueState>(
        bloc: _bloc,
        listener: (context, state) {
          if (state.acao == AcaoEstoque.produtoDeletado) {
            CustomToast.show(context, message: 'Peça excluída com sucesso', type: ToastType.sucesso);
          } else if (state.acao == AcaoEstoque.produtoSalvo) {
            CustomToast.show(context, message: 'Peça salva com sucesso', type: ToastType.sucesso);
          } else if (state.erro != null) {
            CustomToast.show(context, message: state.erro!, type: ToastType.erro);
          }
        },
        builder: (context, state) {
          if (state.carregando && state.categorias.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.erro != null && state.categorias.isEmpty) {
            return _construirErro(state.erro!);
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _construirCabecalho(state),
                const SizedBox(height: 24),
                _construirKpis(state),
                const SizedBox(height: 28),
                if (state.carregando)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(48),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else
                  _construirConteudo(state),
              ],
            ),
          );
        },
      ),
    );
  }


  Widget _construirCabecalho(EstoqueState state) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _construirBreadcrumb(state),
              const SizedBox(height: 6),
              Text(
                _tituloAtual(state),
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                _subtituloAtual(state),
                style: const TextStyle(color: AppColors.textoSecundario, fontSize: 14),
              ),
            ],
          ),
        ),
        const SizedBox(width: 24),
        Row(
          children: [
            SizedBox(
              width: 280,
              child: TextField(
                controller: _buscaController,
                onChanged: (v) => _bloc.add(BuscaAlterada(v)),
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Buscar por nome ou código...',
                  hintStyle: const TextStyle(color: Colors.white38),
                  prefixIcon: const Icon(Icons.search, color: Colors.white38, size: 18),
                  filled: true,
                  fillColor: AppColors.fundoCard,
                  contentPadding: EdgeInsets.zero,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.borda),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.primaria),
                  ),
                ),
              ),
            ),
            if (state.nivel == NivelEstoque.produtos) ...[
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: _mostrarModalProduto,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Nova Peça', style: TextStyle(fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaria,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _construirBreadcrumb(EstoqueState state) {
    final items = <Widget>[];

    _adicionarItemBreadcrumb(
      items,
      'Estoque',
      state.nivel != NivelEstoque.categorias
          ? () {
              _buscaController.clear();
              _bloc.add(BreadcrumbTocado(NivelEstoque.categorias));
            }
          : null,
    );

    if (state.nivel == NivelEstoque.subcategorias || state.nivel == NivelEstoque.produtos) {
      items.add(_separadorBreadcrumb());
      _adicionarItemBreadcrumb(
        items,
        state.catNomeSelecionada ?? '',
        state.nivel == NivelEstoque.produtos
            ? () {
                _buscaController.clear();
                _bloc.add(BreadcrumbTocado(NivelEstoque.subcategorias));
              }
            : null,
      );
    }

    if (state.nivel == NivelEstoque.produtos) {
      items.add(_separadorBreadcrumb());
      _adicionarItemBreadcrumb(items, state.subNomeSelecionada ?? '', null);
    }

    return Row(children: items);
  }

  void _adicionarItemBreadcrumb(List<Widget> items, String label, VoidCallback? onTap) {
    items.add(
      onTap != null
          ? GestureDetector(
              onTap: onTap,
              child: Text(
                label,
                style: const TextStyle(color: AppColors.textoSecundario, fontSize: 13),
              ),
            )
          : Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
            ),
    );
  }

  Widget _separadorBreadcrumb() => const Padding(
    padding: EdgeInsets.symmetric(horizontal: 6),
    child: Text('/', style: TextStyle(color: AppColors.textoSecundario, fontSize: 13)),
  );

  String _tituloAtual(EstoqueState state) => switch (state.nivel) {
    NivelEstoque.categorias => 'Gestão de Estoque',
    NivelEstoque.subcategorias => state.catNomeSelecionada ?? 'Subcategorias',
    NivelEstoque.produtos => state.subNomeSelecionada ?? 'Produtos',
  };

  String _subtituloAtual(EstoqueState state) => switch (state.nivel) {
    NivelEstoque.categorias => 'Controle de peças e insumos da oficina',
    NivelEstoque.subcategorias => '${state.subcategorias.length} subcategoria${state.subcategorias.length == 1 ? '' : 's'}',
    NivelEstoque.produtos =>
      '${state.catNomeSelecionada ?? ''} · ${state.produtos.length} produto${state.produtos.length == 1 ? '' : 's'}',
  };


  Widget _construirKpis(EstoqueState state) {
    int pecas = state.totalPecasFisicas;
    double valor = state.valorTotalEstoque;
    double valorVenda = state.valorTotalVenda;

    if (state.nivel == NivelEstoque.subcategorias && state.catIdSelecionada != null) {
      try {
        final cat = state.categorias.firstWhere((c) => c.id == state.catIdSelecionada);
        pecas = cat.quantidadePecas;
        valor = cat.valorTotal;
        valorVenda = cat.valorTotalVenda;
      } catch (_) {}
    } else if (state.nivel == NivelEstoque.produtos) {
      pecas = 0;
      valor = 0.0;
      valorVenda = 0.0;
      for (var p in state.produtos) {
        pecas += p.quantidadeEmEstoque;
        valor += p.quantidadeEmEstoque * p.precoCusto;
        valorVenda += p.quantidadeEmEstoque * p.precoVenda;
      }
    }

    final isWide = MediaQuery.of(context).size.width > 900;
    final cards = [
      Expanded(
        child: _construirCardKpi(
          icon: Icons.inventory_2_outlined,
          cor: AppColors.primaria,
          titulo: 'Itens Cadastrados',
          valor: '${state.totalItens}',
          subtitulo: 'SKUs cadastrados',
        ),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: _construirCardKpi(
          icon: Icons.archive_outlined,
          cor: AppColors.emAndamento,
          titulo: 'Peças em Estoque',
          valor: '$pecas',
          subtitulo: 'Soma das quantidades',
        ),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: _construirCardKpi(
          icon: Icons.attach_money_outlined,
          cor: const Color(0xFFB79DFB),
          titulo: 'Custo do Estoque',
          valor: 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}',
          subtitulo: 'Valor pago nas peças',
        ),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: _construirCardKpi(
          icon: Icons.point_of_sale_outlined,
          cor: const Color(0xFF4CAF50),
          titulo: 'Prev. Faturamento',
          valor: 'R\$ ${valorVenda.toStringAsFixed(2).replaceAll('.', ',')}',
          subtitulo: 'Valor de venda',
        ),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: _construirCardKpi(
          icon: Icons.warning_amber_outlined,
          cor: AppColors.atencao,
          titulo: 'Estoque Baixo',
          valor: '${state.totalBaixo}',
          subtitulo: 'Itens em alerta',
        ),
      ),
    ];
    return isWide ? Row(children: cards) : Column(children: cards);
  }

  Widget _construirCardKpi({
    required IconData icon,
    required Color cor,
    required String titulo,
    required String valor,
    required String subtitulo,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.fundoCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borda),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: cor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: cor, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, style: const TextStyle(color: AppColors.textoSecundario, fontSize: 13)),
                const SizedBox(height: 4),
                Text(
                  valor,
                  style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(subtitulo, style: const TextStyle(color: AppColors.textoSecundario, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _construirConteudo(EstoqueState state) => switch (state.nivel) {
    NivelEstoque.categorias => _construirCategorias(state),
    NivelEstoque.subcategorias => _construirSubcategorias(state),
    NivelEstoque.produtos => _construirProdutos(state),
  };

  Widget _construirCategorias(EstoqueState state) {
    final busca = state.busca.toLowerCase();
    final lista = busca.isEmpty
        ? state.categorias
        : state.categorias.where((c) => c.nome.toLowerCase().contains(busca)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Categorias',
              style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600),
            ),
            Text(
              '${lista.length} itens',
              style: const TextStyle(color: AppColors.textoSecundario, fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 16),
        lista.isEmpty
            ? _construirVazio(state.busca.isEmpty ? 'Nenhuma categoria cadastrada.' : 'Nenhuma categoria encontrada.')
            : GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: MediaQuery.of(context).size.width > 900 ? 4 : 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.5,
                ),
                itemCount: lista.length,
                itemBuilder: (context, index) {
                  final cat = lista[index];
                  final cor = _corCategoria(index, cat.nome);

                  return _construirTileCard(
                    nome: cat.nome,
                    subtitulo: '${cat.totalItens} iten${cat.totalItens == 1 ? '' : 's'}',
                    cor: cor,
                    onTap: () {
                      _buscaController.clear();
                      _bloc.add(BuscaAlterada(''));
                      _bloc.add(CategoriaSelecionada(cat.id, cat.nome));
                    },
                  );
                },
              ),
      ],
    );
  }

  Widget _construirSubcategorias(EstoqueState state) {
    final busca = state.busca.toLowerCase();
    final lista = busca.isEmpty
        ? state.subcategorias
        : state.subcategorias.where((s) => s.nome.toLowerCase().contains(busca)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Subcategorias',
              style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600),
            ),
            Text(
              '${lista.length} itens',
              style: const TextStyle(color: AppColors.textoSecundario, fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 16),
        lista.isEmpty
            ? _construirVazio(state.busca.isEmpty ? 'Nenhuma subcategoria cadastrada.' : 'Nenhuma subcategoria encontrada.')
            : GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: MediaQuery.of(context).size.width > 900 ? 4 : 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.5,
                ),
                itemCount: lista.length,
                itemBuilder: (context, index) {
                  final sub = lista[index];
                  return _construirTileCard(
                    nome: sub.nome,
                    subtitulo: 'Ver produtos',
                    cor: AppColors.primaria,
                    onTap: () {
                      _buscaController.clear();
                      _bloc.add(BuscaAlterada(''));
                      _bloc.add(SubcategoriaSelecionada(sub.id, sub.nome));
                    },
                  );
                },
              ),
      ],
    );
  }

  Widget _construirProdutos(EstoqueState state) {
    final busca = state.busca.toLowerCase();
    final todosFiltrados = state.produtos.where((p) {
      final matchBusca = busca.isEmpty || p.nome.toLowerCase().contains(busca);
      final statusProduto = _statusProduto(p);
      final matchStatus = state.filtroStatus == null || statusProduto == state.filtroStatus;
      return matchBusca && matchStatus;
    }).toList();

    final qtdEmEstoque = state.produtos.where((p) => _statusProduto(p) == StatusEstoque.emEstoque).length;
    final qtdBaixo = state.produtos.where((p) => _statusProduto(p) == StatusEstoque.baixo).length;
    final qtdEsgotado = state.produtos.where((p) => _statusProduto(p) == StatusEstoque.esgotado).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _construirChipFiltro(
                'Todos ${state.produtos.length}',
                state.filtroStatus == null,
                () => _bloc.add(FiltroStatusAlterado(null)),
              ),
              const SizedBox(width: 8),
              _construirChipStatus(
                'Em estoque $qtdEmEstoque',
                StatusEstoque.emEstoque,
                state.filtroStatus,
                AppColors.concluido,
              ),
              const SizedBox(width: 8),
              _construirChipStatus(
                'Baixo $qtdBaixo',
                StatusEstoque.baixo,
                state.filtroStatus,
                AppColors.atencao,
              ),
              const SizedBox(width: 8),
              _construirChipStatus(
                'Esgotado $qtdEsgotado',
                StatusEstoque.esgotado,
                state.filtroStatus,
                AppColors.erro,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: AppColors.fundoCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borda),
          ),
          child: todosFiltrados.isEmpty
              ? _construirVazio(
                  state.busca.isEmpty && state.filtroStatus == null
                      ? 'Nenhuma peça cadastrada.'
                      : 'Nenhuma peça encontrada.',
                )
              : Column(
                  children: [
                    _construirHeaderTabela(),
                    const Divider(height: 1, color: AppColors.borda),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: todosFiltrados.length,
                      separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.borda),
                      itemBuilder: (context, index) => _construirLinhaTabela(todosFiltrados[index]),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _construirChipFiltro(String label, bool ativo, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: ativo ? AppColors.primaria.withValues(alpha: 0.15) : AppColors.fundoCard,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: ativo ? AppColors.primaria : AppColors.borda),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: ativo ? AppColors.primaria : AppColors.textoSecundario,
            fontSize: 13,
            fontWeight: ativo ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _construirChipStatus(
    String label,
    StatusEstoque status,
    StatusEstoque? filtroAtivo,
    Color cor,
  ) {
    final ativo = filtroAtivo == status;
    return GestureDetector(
      onTap: () => _bloc.add(FiltroStatusAlterado(ativo ? null : status)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: ativo ? cor.withValues(alpha: 0.15) : AppColors.fundoCard,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: ativo ? cor : AppColors.borda),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: cor, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: ativo ? cor : AppColors.textoSecundario,
                fontSize: 13,
                fontWeight: ativo ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirHeaderTabela() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: const [
          Expanded(
            flex: 4,
            child: Text(
              'PEÇA',
              style: TextStyle(color: AppColors.textoSecundario, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.8),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'ESTOQUE',
              style: TextStyle(color: AppColors.textoSecundario, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.8),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'PREÇO VENDA',
              style: TextStyle(color: AppColors.textoSecundario, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.8),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'STATUS',
              style: TextStyle(color: AppColors.textoSecundario, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.8),
            ),
          ),
          SizedBox(
            width: 80,
            child: Text(
              'AÇÕES',
              textAlign: TextAlign.right,
              style: TextStyle(color: AppColors.textoSecundario, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirLinhaTabela(ProdutoModel produto) {
    final status = _statusProduto(produto);
    final (corStatus, labelStatus) = switch (status) {
      StatusEstoque.emEstoque => (AppColors.concluido, 'Em estoque'),
      StatusEstoque.baixo => (AppColors.atencao, 'Estoque baixo'),
      StatusEstoque.esgotado => (AppColors.erro, 'Esgotado'),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  produto.nome,
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  'P-${produto.id.toString().padLeft(4, '0')}',
                  style: const TextStyle(
                    color: AppColors.textoSecundario,
                    fontSize: 12,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${produto.quantidadeEmEstoque} un.',
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'R\$ ${produto.precoVenda.toStringAsFixed(2)}',
              style: const TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'monospace'),
            ),
          ),
          Expanded(
            flex: 2,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: corStatus.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(color: corStatus, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      labelStatus,
                      style: TextStyle(
                        color: corStatus,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            width: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: AppColors.textoSecundario, size: 18),
                  onPressed: () => _mostrarModalProduto(produto: produto),
                  splashRadius: 20,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppColors.erro, size: 18),
                  onPressed: () => _confirmarDelecaoProduto(produto.id, produto.nome),
                  splashRadius: 20,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirTileCard({
    required String nome,
    required String subtitulo,
    required Color cor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.fundoCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borda),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: cor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      nome.isNotEmpty ? nome[0].toUpperCase() : '?',
                      style: TextStyle(color: cor, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.chevron_right,
                    color: AppColors.textoSecundario.withValues(alpha: 0.5),
                    size: 20,
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nome,
                    style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitulo,
                    style: const TextStyle(color: AppColors.textoSecundario, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _construirVazio(String mensagem) {
    return Container(
      padding: const EdgeInsets.all(48),
      alignment: Alignment.center,
      child: Text(mensagem, style: const TextStyle(color: AppColors.textoSecundario)),
    );
  }

  Widget _construirErro(String mensagem) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: AppColors.erro, size: 48),
          const SizedBox(height: 16),
          Text(mensagem, style: const TextStyle(color: Colors.white)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _bloc.add(EstoqueCarregado()),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaria,
              foregroundColor: Colors.white,
            ),
            child: const Text('Tentar Novamente'),
          ),
        ],
      ),
    );
  }

  Widget _construirLabel(String label) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      label,
      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
    ),
  );

  Widget _construirCampo(
    TextEditingController controller,
    String hint, {
    bool isNumero = false,
  }) =>
      TextField(
        controller: controller,
        keyboardType: isNumero ? TextInputType.number : TextInputType.text,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white24),
          filled: true,
          fillColor: AppColors.fundoPrincipal,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.borda),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.primaria),
          ),
        ),
      );
}
