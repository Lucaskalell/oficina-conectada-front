import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oficina_conectada_front/models/ordem_de_servico_model.dart';
import 'package:oficina_conectada_front/models/cliente_model.dart';
import 'package:oficina_conectada_front/models/carro_model.dart';
import 'package:oficina_conectada_front/widgets/toast/custom_toast.dart';
import 'package:oficina_conectada_front/constants/oficina_strings.dart';
import 'package:oficina_conectada_front/constants/colors.dart';
import 'package:oficina_conectada_front/views/ordem_de_servico/editar_ordem_view.dart';
import 'package:oficina_conectada_front/controllers/ordem_de_servico/adicionar_ordem_controller.dart';
import 'package:oficina_conectada_front/controllers/ordem_de_servico/adicionar_ordem_event.dart';
import 'package:oficina_conectada_front/controllers/ordem_de_servico/adicionar_ordem_state.dart';
import 'package:oficina_conectada_front/services/ordem_de_servico_service.dart';
import 'package:dotted_border/dotted_border.dart' as db;

class AdicionarOrdemView extends StatefulWidget {
  const AdicionarOrdemView({super.key});

  @override
  State<AdicionarOrdemView> createState() => _AdicionarOrdemViewState();
}

class _AdicionarOrdemViewState extends State<AdicionarOrdemView> {
  late AdicionarOrdemController _controller;
  final _formKey = GlobalKey<FormState>();

  List<ClienteModel> _clientesCadastrados = [];
  List<CarroModel> _carrosDoCliente = [];
  List<PlatformFile> _fotosSelecionadas = [];

  String _searchQuery = '';

  ClienteModel? _selectedCliente;
  CarroModel? _selectedCarro;

  final _descricaoServicoController = TextEditingController();
  final _valorTotalController = TextEditingController();
  final _observacoesController = TextEditingController();
  final _mecanicoController = TextEditingController();

  String? _prioridadeSelecionada = 'MEDIA';

  @override
  void initState() {
    super.initState();
    _controller = AdicionarOrdemController(OrdemDeServicoService());
    _controller.add(CarregarClientesEvent());
  }

  @override
  void dispose() {
    _descricaoServicoController.dispose();
    _valorTotalController.dispose();
    _observacoesController.dispose();
    _mecanicoController.dispose();
    _controller.close();
    super.dispose();
  }

  Future<void> _selecionarFotos() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
        withData: kIsWeb,
      );
      if (result != null) {
        setState(() {
          _fotosSelecionadas.addAll(result.files);
        });
      }
    } catch (e) {
      debugPrint('Erro ao selecionar fotos: $e');
      if (mounted) {
        CustomToast.show(
          context,
          message: 'Erro ao selecionar fotos',
          type: ToastType.error,
        );
      }
    }
  }

  void _removerFoto(PlatformFile foto) {
    setState(() {
      _fotosSelecionadas.remove(foto);
    });
  }

  void _abrirModalNovoCliente() async {
    final result = await showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (dialogContext) => BlocProvider.value(
            value: _controller,
            child: Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600, maxHeight: 600),
                child: const EditarOrdemView(),
              ),
            ),
          ),
    );

    if (result == true) {
      _controller.add(CarregarClientesEvent());
    }
  }

  void _enviarFormulario() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedCliente == null || _selectedCarro == null) {
        CustomToast.show(
          context,
          message: 'Selecione um cliente e um veículo',
          type: ToastType.error,
        );
        return;
      }

      final novaOrdem = OrdemDeServicoModel(
        clienteId: _selectedCliente!.id,
        carroId: _selectedCarro!.id,
        defeito: _observacoesController.text,
        descricaoServico: _descricaoServicoController.text,
        valorTotal:
            double.tryParse(_valorTotalController.text.replaceAll('R\$', '').trim()) ??
            0.0,
        mecanicoResponsavel: _mecanicoController.text,
        prioridade: _prioridadeSelecionada,
      );

      _controller.add(CriarOrdemDeServicoEvent(novaOrdem));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AdicionarOrdemController, AdicionarOrdemState>(
      bloc: _controller,
      listener: (context, state) {
        if (state is ClientesCarregadosState) {
          setState(() => _clientesCadastrados = state.clientes);
        } else if (state is DadosClienteCompletoCarregadosState) {
          setState(() => _carrosDoCliente = state.carros);
        } else if (state is AdicionarOrdemSuccessState) {
          CustomToast.show(
            context,
            message: OficinaStrings.ordemDeServicoCriadaComSucesso,
            type: ToastType.success,
          );
          Navigator.pop(context, true);
        } else if (state is AdicionarOrdemErrorState) {
          CustomToast.show(context, message: state.message, type: ToastType.error);
        }
      },
      builder: (context, state) {
        final isLoading = state is AdicionarOrdemLoadingState;

        return Scaffold(
          backgroundColor: ColorsApp.bgDark,
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
                      Expanded(flex: 2, child: _buildPainelClientes()),
                      const SizedBox(width: 24),
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
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
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
    final clientesFiltrados =
        _clientesCadastrados.where((c) {
          return c.nome.toLowerCase().contains(_searchQuery.toLowerCase());
        }).toList();

    return Container(
      decoration: BoxDecoration(
        color: ColorsApp.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorsApp.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '1. Selecionar Cliente',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                InkWell(
                  onTap: _abrirModalNovoCliente,
                  borderRadius: BorderRadius.circular(4),
                  child: Row(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white54),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Novo cliente',
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Buscar por nome...',
                hintStyle: const TextStyle(color: Colors.white24),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Colors.white24,
                  size: 18,
                ),
                filled: true,
                fillColor: ColorsApp.bgDark,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: ColorsApp.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: ColorsApp.primaryColor),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
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
                    _controller.add(CarregarDadosClienteCompletoEvent(cliente.id!));
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? ColorsApp.primaryColor.withOpacity(0.05)
                              : ColorsApp.bgDark,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color:
                            isSelected ? ColorsApp.primaryColor : ColorsApp.border,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color:
                                isSelected
                                    ? ColorsApp.primaryColor.withOpacity(0.2)
                                    : ColorsApp.cardDark,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            cliente.nome.substring(0, 2).toUpperCase(),
                            style: TextStyle(
                              color:
                                  isSelected
                                      ? ColorsApp.primaryColor
                                      : Colors.white54,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                cliente.nome,
                                style: TextStyle(
                                  color:
                                      isSelected
                                          ? ColorsApp.primaryColor
                                          : Colors.white,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                              const Text(
                                '(00) 00000-0000',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          const Icon(
                            Icons.check_circle,
                            color: ColorsApp.primaryColor,
                            size: 18,
                          ),
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
      return _buildEmptyState(
        'Selecione um cliente',
        'Escolha um cliente da lista ao lado ou marque a opção "Novo cliente".',
        Icons.build,
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: ColorsApp.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorsApp.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '2. Selecionar Veículo',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
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
                    width: 250,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? ColorsApp.primaryColor.withOpacity(0.05)
                              : ColorsApp.bgDark,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color:
                            isSelected ? ColorsApp.primaryColor : ColorsApp.border,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.directions_car,
                          color: isSelected ? ColorsApp.primaryColor : Colors.white54,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                carro.modelo,
                                style: TextStyle(
                                  color:
                                      isSelected
                                          ? ColorsApp.primaryColor
                                          : Colors.white,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                '${carro.placa} - Cor/Ano',
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 11,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          const Icon(
                            Icons.check_circle,
                            color: ColorsApp.primaryColor,
                            size: 16,
                          ),
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
        return _buildEmptyState(
          'Selecione o veículo',
          'Escolha um dos veículos de ${_selectedCliente!.nome} para continuar.',
          Icons.directions_car,
        );
      }
      return const SizedBox();
    }

    return Container(
      decoration: BoxDecoration(
        color: ColorsApp.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorsApp.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              '3. Dados do Serviço',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
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
                    decoration: _inputDecoration(
                      'Descreva o serviço a ser realizado...',
                    ),
                    validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInputLabel('Mecânico Responsável'),
                            TextFormField(
                              controller: _mecanicoController,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                              decoration: _inputDecoration('Nome do mecânico...'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInputLabel('Prioridade'),
                            DropdownButtonFormField<String>(
                              value: _prioridadeSelecionada,
                              dropdownColor: ColorsApp.cardDark,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                              decoration: _inputDecoration('Selecionar'),
                              items: const [
                                DropdownMenuItem(value: 'BAIXA', child: Text('Baixa')),
                                DropdownMenuItem(value: 'MEDIA', child: Text('Média')),
                                DropdownMenuItem(
                                  value: 'ALTA',
                                  child: Text(
                                    'Alta',
                                    style: TextStyle(color: ColorsApp.laranja),
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'URGENTE',
                                  child: Text(
                                    'Urgente',
                                    style: TextStyle(color: ColorsApp.vermelhoToast),
                                  ),
                                ),
                              ],
                              onChanged:
                                  (v) => setState(() => _prioridadeSelecionada = v),
                            ),
                          ],
                        ),
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
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                              decoration: _inputDecoration('R\$0,00'),
                            ),
                          ],
                        ),
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
                  const SizedBox(height: 16),
                  _buildPainelFotos(),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: ColorsApp.border)),
              color: ColorsApp.bgDark.withOpacity(0.5),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text(
                      'Cliente: ',
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                    Text(
                      _selectedCliente!.nome,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Veículo: ',
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                    Text(
                      '${_selectedCarro!.modelo} (${_selectedCarro!.placa})',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: isLoading ? null : _enviarFormulario,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorsApp.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon:
                      isLoading
                          ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : const Icon(Icons.build, size: 16),
                  label: Text(
                    isLoading ? 'Abrindo...' : 'Abrir OS',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white24),
      filled: true,
      fillColor: ColorsApp.bgDark,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: ColorsApp.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: ColorsApp.primaryColor),
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: ColorsApp.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorsApp.border),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ColorsApp.bgDark,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: Colors.white24, size: 32),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPainelFotos() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInputLabel('Registros Fotográficos (Opcional)'),
        InkWell(
          onTap: _selecionarFotos,
          borderRadius: BorderRadius.circular(12),
          child: db.DottedBorder(
            options: const db.RoundedRectDottedBorderOptions(
              radius: Radius.circular(12),
              dashPattern: [6, 4],
              color: ColorsApp.border,
              strokeWidth: 1.5,
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
              decoration: BoxDecoration(
                color: ColorsApp.bgDark,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: ColorsApp.cardDark,
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(color: ColorsApp.border),
                    ),
                    child: const Icon(
                      Icons.cloud_upload_outlined,
                      color: ColorsApp.primaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Clique para fazer upload das fotos do veículo',
                    style: TextStyle(
                      color: ColorsApp.textForeground,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tire fotos com seu aparelho (KM, avarias) e coloque-as aqui.',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'Aceita PNG, JPG até 5MB.',
                    style: TextStyle(
                      color: ColorsApp.textMuted.withOpacity(0.5),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_fotosSelecionadas.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            '${_fotosSelecionadas.length} foto(s) selecionada(s):',
            style: const TextStyle(
              color: ColorsApp.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 200),
            child: GridView.builder(
              shrinkWrap: true,
              itemCount: _fotosSelecionadas.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemBuilder: (context, index) {
                final foto = _fotosSelecionadas[index];
                return Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: ColorsApp.border),
                        image: DecorationImage(
                          image: MemoryImage(foto.bytes!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: InkWell(
                        onTap: () => _removerFoto(foto),
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: ColorsApp.vermelhoToast,
                            size: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
        const SizedBox(height: 24),
      ],
    );
  }
}
