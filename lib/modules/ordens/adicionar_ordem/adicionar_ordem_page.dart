import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dotted_border/dotted_border.dart' as db;
import 'package:oficina_conectada_front/core/constants/app_colors.dart';
import 'package:oficina_conectada_front/models/carro_model.dart';
import 'package:oficina_conectada_front/models/cliente_model.dart';
import 'package:oficina_conectada_front/modules/ordens/adicionar_ordem/adicionar_ordem_bloc.dart';
import 'package:oficina_conectada_front/modules/ordens/adicionar_ordem/adicionar_ordem_event.dart';
import 'package:oficina_conectada_front/modules/ordens/adicionar_ordem/adicionar_ordem_state.dart';
import 'package:oficina_conectada_front/modules/ordens/adicionar_ordem/cadastrar_cliente/cadastrar_cliente_page.dart';
import 'package:oficina_conectada_front/modules/ordens/ordens_model.dart';
import 'package:oficina_conectada_front/modules/ordens/ordens_service.dart';
import 'package:oficina_conectada_front/shared/widgets/custom_toast/custom_toast.dart';

class AdicionarOrdemPage extends StatefulWidget {
  const AdicionarOrdemPage({super.key});

  @override
  State<AdicionarOrdemPage> createState() => _AdicionarOrdemPageState();
}

class _AdicionarOrdemPageState extends State<AdicionarOrdemPage> {


  late AdicionarOrdemBloc _adicionarOrdemBloc;
  late OrdensService _ordensService;
  late TextEditingController _descricaoController;
  late TextEditingController _valorTotalController;
  late TextEditingController _observacoesController;
  late TextEditingController _mecanicoController;
  late GlobalKey<FormState> _formKey;


  List<ClienteModel> _clientes = [];
  List<CarroModel> _carrosDoCliente = [];
  final List<PlatformFile> _fotosSelecionadas = [];
  String _textoBusca = '';
  ClienteModel? _clienteSelecionado;
  CarroModel? _carroSelecionado;
  String? _prioridadeSelecionada = 'MEDIA';


  Future<void> _selecionarFotos() async {
    try {
      final resultado = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
        withData: kIsWeb,
      );
      if (resultado != null) {
        setState(() => _fotosSelecionadas.addAll(resultado.files));
      }
    } catch (e) {
      if (mounted) {
        CustomToast.show(context, message: 'Erro ao selecionar fotos', type: ToastType.erro);
      }
    }
  }

  void _removerFoto(PlatformFile foto) {
    setState(() => _fotosSelecionadas.remove(foto));
  }

  void _abrirModalNovoCliente() async {
    final resultado = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => BlocProvider.value(
        value: _adicionarOrdemBloc,
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600, maxHeight: 600),
            child: const CadastrarClientePage(),
          ),
        ),
      ),
    );
    if (resultado == true) {
      _adicionarOrdemBloc.add(CarregarClientes());
    }
  }

  void _enviarFormulario() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_clienteSelecionado == null || _carroSelecionado == null) {
      CustomToast.show(context, message: 'Selecione um cliente e um veículo', type: ToastType.atencao);
      return;
    }

    final novaOrdem = OrdemDeServicoModel(
      clienteId: _clienteSelecionado!.id,
      carroId: _carroSelecionado!.id,
      defeito: _observacoesController.text,
      descricaoServico: _descricaoController.text,
      valorTotal:
          double.tryParse(_valorTotalController.text.replaceAll('R\$', '').trim()) ?? 0.0,
      mecanicoResponsavel: _mecanicoController.text,
      prioridade: _prioridadeSelecionada,
    );

    _adicionarOrdemBloc.add(CriarOrdem(novaOrdem));
  }


  @override
  void initState() {
    super.initState();
    _ordensService = OrdensService();
    _adicionarOrdemBloc = AdicionarOrdemBloc(_ordensService);
    _descricaoController = TextEditingController();
    _valorTotalController = TextEditingController();
    _observacoesController = TextEditingController();
    _mecanicoController = TextEditingController();
    _formKey = GlobalKey<FormState>();
    _adicionarOrdemBloc.add(CarregarClientes());
  }


  Widget _construirHeader() {
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
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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

  Widget _construirPainelClientes() {
    final clientesFiltrados = _clientes
        .where((c) => c.nome.toLowerCase().contains(_textoBusca.toLowerCase()))
        .toList();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.fundoCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borda),
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
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
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
                      const Text('Novo cliente', style: TextStyle(color: Colors.white54, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              onChanged: (v) => setState(() => _textoBusca = v),
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Buscar por nome...',
                hintStyle: const TextStyle(color: Colors.white24),
                prefixIcon: const Icon(Icons.search, color: Colors.white24, size: 18),
                filled: true,
                fillColor: AppColors.fundoPrincipal,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
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
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: clientesFiltrados.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final cliente = clientesFiltrados[index];
                final selecionado = _clienteSelecionado?.id == cliente.id;

                return InkWell(
                  onTap: () {
                    setState(() {
                      _clienteSelecionado = cliente;
                      _carroSelecionado = null;
                      _carrosDoCliente = [];
                    });
                    _adicionarOrdemBloc.add(CarregarCarrosCliente(cliente.id!));
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: selecionado
                          ? AppColors.primaria.withValues(alpha: 0.05)
                          : AppColors.fundoPrincipal,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: selecionado ? AppColors.primaria : AppColors.borda,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: selecionado
                                ? AppColors.primaria.withValues(alpha: 0.2)
                                : AppColors.fundoCard,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            cliente.nome.substring(0, 2).toUpperCase(),
                            style: TextStyle(
                              color: selecionado ? AppColors.primaria : Colors.white54,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            cliente.nome,
                            style: TextStyle(
                              color: selecionado ? AppColors.primaria : Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        if (selecionado)
                          const Icon(Icons.check_circle, color: AppColors.primaria, size: 18),
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

  Widget _construirPainelVeiculos() {
    if (_clienteSelecionado == null) {
      return _construirEstadoVazio(
        'Selecione um cliente',
        'Escolha um cliente da lista ao lado ou cadastre um novo.',
        Icons.build,
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.fundoCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borda),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '2. Selecionar Veículo',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(height: 16),
          if (_carrosDoCliente.isEmpty)
            const Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaria))
          else
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _carrosDoCliente.map((carro) {
                final selecionado = _carroSelecionado?.id == carro.id;
                return InkWell(
                  onTap: () => setState(() => _carroSelecionado = carro),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 250,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: selecionado
                          ? AppColors.primaria.withValues(alpha: 0.05)
                          : AppColors.fundoPrincipal,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: selecionado ? AppColors.primaria : AppColors.borda,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.directions_car,
                            color: selecionado ? AppColors.primaria : Colors.white54, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                carro.modelo,
                                style: TextStyle(
                                  color: selecionado ? AppColors.primaria : Colors.white,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                carro.placa,
                                style: const TextStyle(color: Colors.white54, fontSize: 11),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        if (selecionado)
                          const Icon(Icons.check_circle, color: AppColors.primaria, size: 16),
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

  Widget _construirPainelServico(bool carregando) {
    if (_carroSelecionado == null) {
      if (_clienteSelecionado != null && _carrosDoCliente.isNotEmpty) {
        return _construirEstadoVazio(
          'Selecione o veículo',
          'Escolha um dos veículos de ${_clienteSelecionado!.nome} para continuar.',
          Icons.directions_car,
        );
      }
      return const SizedBox();
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.fundoCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borda),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              '3. Dados do Serviço',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _construirLabelInput('Descrição do Serviço'),
                  TextFormField(
                    controller: _descricaoController,
                    maxLines: 3,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: _decoracaoInput('Descreva o serviço a ser realizado...'),
                    validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _construirLabelInput('Mecânico Responsável'),
                            TextFormField(
                              controller: _mecanicoController,
                              style: const TextStyle(color: Colors.white, fontSize: 13),
                              decoration: _decoracaoInput('Nome do mecânico...'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _construirLabelInput('Prioridade'),
                            DropdownButtonFormField<String>(
                              value: _prioridadeSelecionada,
                              dropdownColor: AppColors.fundoCard,
                              style: const TextStyle(color: Colors.white, fontSize: 13),
                              decoration: _decoracaoInput('Selecionar'),
                              items: [
                                const DropdownMenuItem(value: 'BAIXA', child: Text('Baixa')),
                                const DropdownMenuItem(value: 'MEDIA', child: Text('Média')),
                                DropdownMenuItem(
                                  value: 'ALTA',
                                  child: Text('Alta', style: TextStyle(color: AppColors.atencao)),
                                ),
                                DropdownMenuItem(
                                  value: 'URGENTE',
                                  child: Text('Urgente', style: TextStyle(color: AppColors.erro)),
                                ),
                              ],
                              onChanged: (v) => setState(() => _prioridadeSelecionada = v),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _construirLabelInput('Valor Estimado'),
                            TextFormField(
                              controller: _valorTotalController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: Colors.white, fontSize: 13),
                              decoration: _decoracaoInput('R\$0,00'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _construirLabelInput('Observações'),
                  TextFormField(
                    controller: _observacoesController,
                    maxLines: 2,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: _decoracaoInput('Informações adicionais...'),
                  ),
                  const SizedBox(height: 16),
                  _construirPainelFotos(),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: const Border(top: BorderSide(color: AppColors.borda)),
              color: AppColors.fundoPrincipal.withValues(alpha: 0.5),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text('Cliente: ', style: TextStyle(color: Colors.white54, fontSize: 12)),
                    Text(
                      _clienteSelecionado!.nome,
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 16),
                    const Text('Veículo: ', style: TextStyle(color: Colors.white54, fontSize: 12)),
                    Text(
                      '${_carroSelecionado!.modelo} (${_carroSelecionado!.placa})',
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: carregando ? null : _enviarFormulario,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaria,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: carregando
                      ? const SizedBox(
                          width: 16, height: 16,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.build, size: 16),
                  label: Text(
                    carregando ? 'Abrindo...' : 'Abrir OS',
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

  Widget _construirLabelInput(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }

  InputDecoration _decoracaoInput(String hint) {
    return InputDecoration(
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
    );
  }

  Widget _construirEstadoVazio(String titulo, String subtitulo, IconData icone) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.fundoCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borda),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.fundoPrincipal,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icone, color: Colors.white24, size: 32),
            ),
            const SizedBox(height: 16),
            Text(titulo, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(subtitulo, style: const TextStyle(color: Colors.white54, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _construirPainelFotos() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _construirLabelInput('Registros Fotográficos (Opcional)'),
        InkWell(
          onTap: _selecionarFotos,
          borderRadius: BorderRadius.circular(12),
          child: db.DottedBorder(
            options: const db.RoundedRectDottedBorderOptions(
              radius: Radius.circular(12),
              dashPattern: [6, 4],
              color: AppColors.borda,
              strokeWidth: 1.5,
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.fundoPrincipal,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.fundoCard,
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(color: AppColors.borda),
                    ),
                    child: const Icon(Icons.cloud_upload_outlined, color: AppColors.primaria, size: 24),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Clique para fazer upload das fotos do veículo',
                    style: TextStyle(color: AppColors.textoPrincipal, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tire fotos com seu aparelho (KM, avarias) e coloque-as aqui.',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'Aceita PNG, JPG até 5MB.',
                    style: TextStyle(color: AppColors.textoSecundario.withValues(alpha: 0.5), fontSize: 11),
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
            style: const TextStyle(color: AppColors.textoSecundario, fontSize: 12, fontWeight: FontWeight.bold),
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
                        border: Border.all(color: AppColors.borda),
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
                          decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                          child: const Icon(Icons.close, color: AppColors.erro, size: 14),
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


  Widget _blocBuilder() {
    return BlocConsumer<AdicionarOrdemBloc, AdicionarOrdemState>(
      bloc: _adicionarOrdemBloc,
      listener: (context, estado) {
        if (estado is ClientesCarregados) {
          setState(() => _clientes = estado.clientes);
        }
        if (estado is CarrosClienteCarregados) {
          setState(() => _carrosDoCliente = estado.carros);
        }
        if (estado is AdicionarOrdemSucesso) {
          CustomToast.show(context, message: 'Ordem de serviço criada com sucesso!', type: ToastType.sucesso);
          Navigator.pop(context, true);
        }
        if (estado is AdicionarOrdemErro) {
          CustomToast.show(context, message: estado.mensagem, type: ToastType.erro);
        }
      },
      builder: (context, estado) {
        final carregando = estado is AdicionarOrdemCarregando;

        return Scaffold(
          backgroundColor: AppColors.fundoPrincipal,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _construirHeader(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 2, child: _construirPainelClientes()),
                      const SizedBox(width: 24),
                      Expanded(
                        flex: 3,
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _construirPainelVeiculos(),
                              const SizedBox(height: 16),
                              Expanded(child: _construirPainelServico(carregando)),
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


  @override
  Widget build(BuildContext context) => _blocBuilder();


  @override
  void dispose() {
    _adicionarOrdemBloc.close();
    _descricaoController.dispose();
    _valorTotalController.dispose();
    _observacoesController.dispose();
    _mecanicoController.dispose();
    super.dispose();
  }
}
