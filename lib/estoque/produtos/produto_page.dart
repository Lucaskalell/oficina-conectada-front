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
  // Controladores do Filtro e Busca
  String _searchQuery = '';
  String _filtroPosicao = 'Todos';

  final _nomeController = TextEditingController();
  final _precoCustoController = TextEditingController();
  final _precoVendaController = TextEditingController();
  final _quantidadeController = TextEditingController();

  // Cores Vercel Style
  final Color _bgDark = const Color(0xFF09090B);
  final Color _cardDark = const Color(0xFF18181B);
  final Color _borderColor = const Color(0xFF27272A);
  final Color _primaryColor = const Color(0xFF10B981);
  final Color _warningColor = const Color(0xFFF59E0B);

  @override
  void dispose() {
    _nomeController.dispose();
    _precoCustoController.dispose();
    _precoVendaController.dispose();
    _quantidadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ProdutoBloc(ProdutoRepository())..add(BuscarProdutos(widget.subCategoriaId)),
      child: Scaffold(
        backgroundColor: _bgDark,
        appBar: AppBar(
          title: Text(
            widget.subCategoriaNome,
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
          ),
          backgroundColor: _bgDark,
          iconTheme: const IconThemeData(color: Colors.white54),
          elevation: 0,
          shape: Border(bottom: BorderSide(color: _borderColor)),
          actions: [
            Builder(
              builder: (context) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: ElevatedButton.icon(
                    onPressed: () => _mostrarModal(context),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Nova Peça', style: TextStyle(fontWeight: FontWeight.w600)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        body: BlocConsumer<ProdutoBloc, ProdutoState>(
          listener: (context, state) {
            if (state is ProdutoError) {
              CustomToast.show(context, message: state.message, type: ToastType.error);
            }
          },
          builder: (context, state) {
            if (state is ProdutoLoading) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFF10B981)));
            } else if (state is ProdutoSuccess) {
              return _buildContent(context, state.produtos);
            } else if (state is ProdutoError) {
              return _buildErrorState(context);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<Produto> produtosApi) {
    final listaFiltrada = produtosApi.where((prod) {
      final matchSearch = prod.nome.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchFiltro =
          _filtroPosicao == 'Todos' ||
          prod.nome.toLowerCase().contains(_filtroPosicao.toLowerCase());
      return matchSearch && matchFiltro;
    }).toList();

    return Column(
      children: [
        // Barra de Filtros
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: _borderColor)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                onChanged: (v) => setState(() => _searchQuery = v),
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Buscar código, nome ou carro...',
                  hintStyle: const TextStyle(color: Colors.white24),
                  prefixIcon: const Icon(Icons.search, color: Colors.white24, size: 18),
                  filled: true,
                  fillColor: _cardDark,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
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
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['Todos', 'Dianteiro', 'Traseiro', 'Esquerdo', 'Direito'].map((filtro) {
                    final isSelected = _filtroPosicao == filtro;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(
                          filtro,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.white54,
                            fontSize: 13,
                          ),
                        ),
                        selected: isSelected,
                        onSelected: (bool selected) => setState(() => _filtroPosicao = filtro),
                        backgroundColor: _cardDark,
                        selectedColor: _primaryColor.withOpacity(0.2),
                        checkmarkColor: _primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: isSelected ? _primaryColor : _borderColor),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),

        // Lista de Peças
        Expanded(
          child: listaFiltrada.isEmpty
              ? const Center(
                  child: Text('Nenhuma peça encontrada.', style: TextStyle(color: Colors.white54)),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(24),
                  itemCount: listaFiltrada.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final prod = listaFiltrada[index];
                    final bool isLowStock = prod.quantidadeEmEstoque < 3;

                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _cardDark,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isLowStock ? _warningColor.withOpacity(0.3) : _borderColor,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _bgDark,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: _borderColor),
                            ),
                            child: Icon(
                              Icons.settings_suggest,
                              color: isLowStock ? _warningColor : Colors.white54,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  prod.nome,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      'Cód: P-${prod.id.toString().padLeft(4, '0')}',
                                      style: const TextStyle(
                                        color: Colors.white38,
                                        fontSize: 12,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isLowStock
                                            ? _warningColor.withOpacity(0.15)
                                            : _primaryColor.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'Estoque: ${prod.quantidadeEmEstoque}',
                                        style: TextStyle(
                                          color: isLowStock ? _warningColor : _primaryColor,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'R\$ ${prod.precoVenda.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'monospace',
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit_outlined,
                                      color: Colors.white54,
                                      size: 18,
                                    ),
                                    onPressed: () =>
                                        _mostrarModal(context, produtoParaEditar: prod),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.redAccent,
                                      size: 18,
                                    ),
                                    onPressed: () =>
                                        _confirmarExclusao(context, prod.id, prod.nome),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _mostrarModal(BuildContext context, {Produto? produtoParaEditar}) {
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
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: _cardDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: _borderColor),
          ),
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isEdicao ? Icons.edit : Icons.add_box_outlined,
                      color: _primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      isEdicao ? 'Editar Peça' : 'Cadastrar Peça',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildInputLabel('Nome da Peça'),
                _buildTextField(_nomeController, 'Ex: Amortecedor Dianteiro'),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInputLabel('Quantidade'),
                          _buildTextField(_quantidadeController, '0', isNumber: true),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInputLabel('Preço Custo'),
                          _buildTextField(_precoCustoController, '0.00', isNumber: true),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildInputLabel('Preço Venda'),
                _buildTextField(_precoVendaController, '0.00', isNumber: true),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        final produto = Produto(
                          id: isEdicao ? produtoParaEditar.id : 0,
                          nome: _nomeController.text,
                          quantidadeEmEstoque: int.tryParse(_quantidadeController.text) ?? 0,
                          precoCusto: double.tryParse(_precoCustoController.text) ?? 0.0,
                          precoVenda: double.tryParse(_precoVendaController.text) ?? 0.0,
                        );

                        if (isEdicao) {
                          context.read<ProdutoBloc>().add(
                            AtualizarProduto(produto, widget.subCategoriaId),
                          );
                        } else {
                          context.read<ProdutoBloc>().add(
                            AdicionarProduto(produto, widget.subCategoriaId),
                          );
                        }
                        Navigator.pop(dialogContext);
                      },
                      child: Text(isEdicao ? 'Atualizar' : 'Cadastrar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmarExclusao(BuildContext context, int id, String nome) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: _cardDark,
        title: const Text('Excluir Peça', style: TextStyle(color: Colors.white)),
        content: Text('Deseja excluir "$nome"?', style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              context.read<ProdutoBloc>().add(DeletarProduto(id, widget.subCategoriaId));
              Navigator.pop(dialogContext);
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
          const SizedBox(height: 16),
          const Text('Erro ao carregar peças', style: TextStyle(color: Colors.white)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.read<ProdutoBloc>().add(BuscarProdutos(widget.subCategoriaId)),
            child: const Text('Tentar Novamente'),
          ),
        ],
      ),
    );
  }

  Widget _buildInputLabel(String label) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      label,
      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
    ),
  );

  Widget _buildTextField(TextEditingController controller, String hint, {bool isNumber = false}) =>
      TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white24),
          filled: true,
          fillColor: _bgDark,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: _borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: _primaryColor),
          ),
        ),
      );
}
