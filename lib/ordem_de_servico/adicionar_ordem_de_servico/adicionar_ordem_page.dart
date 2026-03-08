import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oficina_conectada_front/model/add_ordem_de_servico/ordem_de_servico_model.dart';
import 'package:oficina_conectada_front/model/cliente_model.dart';
import 'package:oficina_conectada_front/model/carro_model.dart';
import 'package:oficina_conectada_front/components/toast/custom_toast.dart';
import 'package:oficina_conectada_front/strings/oficina_strings.dart';

import '../modais/editar_ordem_de_servico_page.dart';
import '../ordem_de_servico_repository.dart';
import 'adicionar_ordem_bloc.dart';
import 'adicionar_ordem_event.dart';
import 'adicionar_ordem_state.dart';

class CriarOrdemDeServicoPage extends StatefulWidget {
  const CriarOrdemDeServicoPage({super.key});

  @override
  State<CriarOrdemDeServicoPage> createState() => _CriarOrdemDeServicoPageState();
}

class _CriarOrdemDeServicoPageState extends State<CriarOrdemDeServicoPage> {
  late AdicionarOrdemDeServicoBloc _bloc;
  final _formKey = GlobalKey<FormState>();

  // Listas do BLoC
  List<ClienteModel> _clientesCadastrados = [];
  List<CarroModel> _carrosDoCliente = [];

  // Filtro de busca
  String _searchQuery = '';

  // Seleções
  ClienteModel? _selectedCliente;
  CarroModel? _selectedCarro;

  // Controllers do Serviço
  final _descricaoServicoController = TextEditingController();
  final _valorTotalController = TextEditingController();
  final _observacoesController = TextEditingController();

  // Dropdowns Mockados (tenho que manda pra consumirem os dados reais )
  String? _mecanicoSelecionado;
  String? _prioridadeSelecionada;

  // Cores
  final Color _bgDark = const Color(0xFF09090B);
  final Color _cardDark = const Color(0xFF18181B); // Zinco 900
  final Color _borderColor = Colors.white.withOpacity(0.1);
  final Color _primaryColor = const Color(0xFF10B981); // Verde

  @override
  void initState() {
    super.initState();
    _bloc = AdicionarOrdemDeServicoBloc(OrdemDeServicoRepository());
    _bloc.add(CarregarClientesEvent());
  }

  @override
  void dispose() {
    _descricaoServicoController.dispose();
    _valorTotalController.dispose();
    _observacoesController.dispose();
    _bloc.close();
    super.dispose();
  }

  void _abrirModalNovoCliente() async {
    final result = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 600),
          child: const EditarOrdemDeServicoPage(),
        ),
      ),
    );

    if (result == true) {
      // Recarregar clientes caso o modal tenha salvo um novo com sucesso
      _bloc.add(CarregarClientesEvent());
    }
  }

  void _enviarFormulario() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedCliente == null || _selectedCarro == null) {
        CustomToast.show(context, message: 'Selecione um cliente e um veículo', type: ToastType.error);
        return;
      }

      final novaOrdem = OrdemDeServicoModel(
        clienteId: _selectedCliente!.id,
        carroId: _selectedCarro!.id,
        defeito: _observacoesController.text, // ou criar campo específico
        descricaoServico: _descricaoServicoController.text,
        valorTotal: double.tryParse(_valorTotalController.text.replaceAll('R\$', '').trim()) ?? 0.0,
      );

      _bloc.add(CriarOrdemDeServicoEvent(novaOrdem));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AdicionarOrdemDeServicoBloc, AdicionarOrdemState>(
      bloc: _bloc,
      listener: (context, state) {
        if (state is ClientesCarregadosState) {
          setState(() => _clientesCadastrados = state.clientes);
        } else if (state is DadosClienteCompletoCarregadosState) {
          setState(() => _carrosDoCliente = state.carros);
        } else if (state is AdicionarOrdemSuccessState) {
          CustomToast.show(context, message: OficinaStrings.ordemDeServicoCriadaComSucesso, type: ToastType.success);
          Navigator.pop(context, true);
        } else if (state is AdicionarOrdemErrorState) {
          CustomToast.show(context, message: state.message, type: ToastType.error);
        }
      },
      builder: (context, state) {
        final isLoading = state is AdicionarOrdemLoadingState;

        return Scaffold(
          backgroundColor: _bgDark,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // COLUNA ESQUERDA: CLIENTES (Ocupa 2/5 do espaço)
                      Expanded(
                        flex: 2,
                        child: _buildPainelClientes(),
                      ),
                      const SizedBox(width: 24),
                      // COLUNA DIREITA: VEÍCULOS E SERVIÇO (Ocupa 3/5 do espaço)
                      Expanded(
                        flex: 3,
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildPainelVeiculos(),
                              const SizedBox(height: 16),
                              Expanded(child: _buildPainelServico(isLoading)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // COMPONENTES PRINCIPAIS DA TELA
//nao esquecer de passar classe string para substitui os textos direto

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white70, size: 20),
            onPressed: () => Navigator.pop(context),
            splashRadius: 24,
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Nova Ordem de Serviço',
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                'Selecione o cliente, veículo e preencha os dados do serviço',
                style: TextStyle(color: Colors.white54, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPainelClientes() {
    final clientesFiltrados = _clientesCadastrados.where((c) {
      return c.nome.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Container(
      decoration: BoxDecoration(color: _cardDark, borderRadius: BorderRadius.circular(12), border: Border.all(color: _borderColor)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header do Card
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('1. Selecionar Cliente', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                InkWell(
                  onTap: _abrirModalNovoCliente,
                  borderRadius: BorderRadius.circular(4),
                  child: Row(
                    children: [
                      Container(
                        width: 16, height: 16,
                        decoration: BoxDecoration(border: Border.all(color: Colors.white54), borderRadius: BorderRadius.circular(4)),
                      ),
                      const SizedBox(width: 8),
                      const Text('Novo cliente', style: TextStyle(color: Colors.white54, fontSize: 12)),
                    ],
                  ),
                )
              ],
            ),
          ),

          // Campo de Busca
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Buscar por nome...',
                hintStyle: const TextStyle(color: Colors.white24),
                prefixIcon: const Icon(Icons.search, color: Colors.white24, size: 18),
                filled: true,
                fillColor: _bgDark, // Fundo mais escuro pro input
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: _borderColor)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: _primaryColor)),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Lista de Clientes
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: clientesFiltrados.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final cliente = clientesFiltrados[index];
                final isSelected = _selectedCliente?.id == cliente.id;

                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedCliente = cliente;
                      _selectedCarro = null;
                      _carrosDoCliente = [];
                    });
                    _bloc.add(CarregarDadosClienteCompletoEvent(cliente.id!));
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected ? _primaryColor.withOpacity(0.05) : _bgDark,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: isSelected ? _primaryColor : _borderColor),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36, height: 36,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSelected ? _primaryColor.withOpacity(0.2) : _cardDark,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            cliente.nome.substring(0, 2).toUpperCase(),
                            style: TextStyle(color: isSelected ? _primaryColor : Colors.white54, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Dados
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(cliente.nome, style: TextStyle(color: isSelected ? _primaryColor : Colors.white, fontWeight: FontWeight.w500, fontSize: 14)),
                              // Usando um telefone fixo para manter o visual, substitua pela prop real do model
                              const Text('(00) 00000-0000', style: TextStyle(color: Colors.white54, fontSize: 12)),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Icon(Icons.check_circle, color: _primaryColor, size: 18),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPainelVeiculos() {
    if (_selectedCliente == null) {
      return _buildEmptyState('Selecione um cliente', 'Escolha um cliente da lista ao lado ou marque a opção "Novo cliente".', Icons.build);
    }

    return Container(
      decoration: BoxDecoration(color: _cardDark, borderRadius: BorderRadius.circular(12), border: Border.all(color: _borderColor)),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('2. Selecionar Veículo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 16),

          if (_carrosDoCliente.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _carrosDoCliente.map((carro) {
                final isSelected = _selectedCarro?.id == carro.id;

                return InkWell(
                  onTap: () => setState(() => _selectedCarro = carro),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 250, // Fixando largura para parecer um card da imagem
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected ? _primaryColor.withOpacity(0.05) : _bgDark,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: isSelected ? _primaryColor : _borderColor),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.directions_car, color: isSelected ? _primaryColor : Colors.white54, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(carro.modelo, style: TextStyle(color: isSelected ? _primaryColor : Colors.white, fontWeight: FontWeight.w500, fontSize: 13)),
                              Text('${carro.placa} - Cor/Ano', style: const TextStyle(color: Colors.white54, fontSize: 11), overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                        if (isSelected) Icon(Icons.check_circle, color: _primaryColor, size: 16),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildPainelServico(bool isLoading) {
    if (_selectedCarro == null) {
      if (_selectedCliente != null && _carrosDoCliente.isNotEmpty) {
        return _buildEmptyState('Selecione o veículo', 'Escolha um dos veículos de ${_selectedCliente!.nome} para continuar.', Icons.directions_car);
      }
      return const SizedBox(); // Oculta se não tiver cliente selecionado
    }

    return Container(
      decoration: BoxDecoration(color: _cardDark, borderRadius: BorderRadius.circular(12), border: Border.all(color: _borderColor)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('3. Dados do Serviço', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildInputLabel('Descrição do Serviço'),
                  TextFormField(
                    controller: _descricaoServicoController,
                    maxLines: 3,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: _inputDecoration('Descreva o serviço a ser realizado...'),
                    validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildInputLabel('Mecânico'),
                              DropdownButtonFormField<String>(
                                value: _mecanicoSelecionado,
                                dropdownColor: _cardDark,
                                style: const TextStyle(color: Colors.white, fontSize: 13),
                                decoration: _inputDecoration('Selecionar'),
                                items: ['João', 'Pedro'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                                onChanged: (v) => setState(() => _mecanicoSelecionado = v),
                              ),
                            ],
                          )
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildInputLabel('Prioridade'),
                              DropdownButtonFormField<String>(
                                value: _prioridadeSelecionada,
                                dropdownColor: _cardDark,
                                style: const TextStyle(color: Colors.white, fontSize: 13),
                                decoration: _inputDecoration('Selecionar'),
                                items: ['Alta', 'Média', 'Baixa'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                                onChanged: (v) => setState(() => _prioridadeSelecionada = v),
                              ),
                            ],
                          )
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildInputLabel('Valor Estimado'),
                              TextFormField(
                                controller: _valorTotalController,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(color: Colors.white, fontSize: 13),
                                decoration: _inputDecoration('R\$ 0,00'),
                              ),
                            ],
                          )
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _buildInputLabel('Observações'),
                  TextFormField(
                    controller: _observacoesController,
                    maxLines: 2,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: _inputDecoration('Informações adicionais...'),
                  ),
                ],
              ),
            ),
          ),

          // Barra inferior de Resumo e Botão
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: _borderColor)),
              color: _bgDark.withOpacity(0.5),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text('Cliente: ', style: TextStyle(color: Colors.white54, fontSize: 12)),
                    Text(_selectedCliente!.nome, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 16),
                    const Text('Veículo: ', style: TextStyle(color: Colors.white54, fontSize: 12)),
                    Text('${_selectedCarro!.modelo} (${_selectedCarro!.placa})', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: isLoading ? null : _enviarFormulario,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: isLoading
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.build, size: 16),
                  label: Text(isLoading ? 'Abrindo...' : 'Abrir OS', style: const TextStyle(fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  // AUXILIARES PRO CC (Para manter o código limpo)


  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white24),
      filled: true,
      fillColor: _bgDark,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: _borderColor)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: _primaryColor)),
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Container(
      decoration: BoxDecoration(color: _cardDark, borderRadius: BorderRadius.circular(12), border: Border.all(color: _borderColor)),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: _bgDark, borderRadius: BorderRadius.circular(16)),
              child: Icon(icon, color: Colors.white24, size: 32),
            ),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}