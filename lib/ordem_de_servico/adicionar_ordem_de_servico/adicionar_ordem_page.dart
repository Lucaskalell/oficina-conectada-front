import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oficina_conectada_front/colors/colors.dart';
import 'package:oficina_conectada_front/model/add_ordem_de_servico/ordem_de_servico_model.dart';
import 'package:oficina_conectada_front/model/cliente_model.dart';
import 'package:oficina_conectada_front/model/carro_model.dart';
import 'package:oficina_conectada_front/ordem_de_servico/modais/editar_ordem_de_servico_page.dart';
import 'package:oficina_conectada_front/strings/oficina_strings.dart';
import 'package:oficina_conectada_front/components/toast/custom_toast.dart';

import '../ordem_de_servico_repository.dart';
import 'adicionar_ordem_bloc.dart';
import 'adicionar_ordem_event.dart';
import 'adicionar_ordem_state.dart';

class CriarOrdemDeServicoPage extends StatefulWidget {
  const CriarOrdemDeServicoPage({super.key});

  @override
  State<CriarOrdemDeServicoPage> createState() => _criarOrdemDeServicoState();
}

class _criarOrdemDeServicoState extends State<CriarOrdemDeServicoPage> {
  late AdicionarOrdemDeServicoBloc _bloc;
  final _formKey = GlobalKey<FormState>();

  final _placaController = TextEditingController();
  final _clienteNomeController = TextEditingController();
  final _carroModeloController = TextEditingController();
  final _defeitoController = TextEditingController();
  final _descricaoServicoController = TextEditingController();
  final _valorTotalController = TextEditingController();

  bool _isClienteNovo = false;
  List<ClienteModel> _clientesCadastrados = [];
  List<CarroModel> _carrosDoCliente = [];

  int? _selectedClienteId;
  int? _selectedCarroId;

  @override
  void initState() {
    super.initState();
    _bloc = AdicionarOrdemDeServicoBloc(OrdemDeServicoRepository());
    _bloc.add(CarregarClientesEvent());
  }

  @override
  void dispose() {
    _placaController.dispose();
    _clienteNomeController.dispose();
    _carroModeloController.dispose();
    _defeitoController.dispose();
    _descricaoServicoController.dispose();
    _valorTotalController.dispose();
    _bloc.close();
    super.dispose();
  }

  void _enviarFormulario() {
    if (_formKey.currentState?.validate() ?? false) {
      final novaOrdem = OrdemDeServicoModel(
        clienteId: _selectedClienteId,
        carroId: _selectedCarroId,
        defeito: _defeitoController.text,
        descricaoServico: _descricaoServicoController.text,
        valorTotal: double.tryParse(_valorTotalController.text) ?? 0.0,
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
          _clientesCadastrados = state.clientes;
        } else if (state is DadosClienteCompletoCarregadosState) {
          _carrosDoCliente = state.carros;
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
          backgroundColor: ColorsApp.preto,
          appBar: AppBar(
            title: const Text(OficinaStrings.novaOrdemDeServico),
            backgroundColor: ColorsApp.preto,
          ),
          body: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildClienteSection(),
                  _buildVeiculoSection(),
                  _buildServicoSection(),
                  const SizedBox(height: 32),
                  _buildSubmitButton(isLoading),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildClienteSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              OficinaStrings.informacoesDoCliente.toUpperCase(),
              style: const TextStyle(color: ColorsApp.azulClaro, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                const Text(OficinaStrings.novoCliente, style: TextStyle(color: Colors.white70)),
                Checkbox(
                  value: _isClienteNovo,
                 onChanged: (v){
                    setState(()=>_isClienteNovo = v!); {
                      if(v==true){
                        _abrirModalNovoCliente();
                      }
                    }
                 },
                ),
              ],
            ),
          ],
        ),
        _isClienteNovo
            ? _buildTextField(
                controller: _clienteNomeController,
                label: OficinaStrings.nomeDoNovoCliente,
                icon: Icons.person_add,
              )
            : _buildDropdownClientes(),
      ],
    );
  }

  void _abrirModalNovoCliente() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: SizedBox(
          width: 600,
          height: 500,
          child:SingleChildScrollView(
          child: const EditarOrdemDeServicoPage(),
        ),
        ),
      ),
    );
  }

  Widget _buildVeiculoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          OficinaStrings.dadosDoVeiculo.toUpperCase(),
          style: const TextStyle(color: ColorsApp.azulClaro, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        _buildDropdownCarros(),
        if (_isClienteNovo) ...[
          _buildTextField(
            controller: _carroModeloController,
            label: OficinaStrings.modeloDoCarro,
            icon: Icons.directions_car,
          ),
          _buildTextField(
            controller: _placaController,
            label: OficinaStrings.placaDoCarro,
            icon: Icons.pin,
          ),
        ],
      ],
    );
  }

  Widget _buildServicoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          OficinaStrings.detalhesDoServico.toUpperCase(),
          style: const TextStyle(color: ColorsApp.azulClaro, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        _buildTextField(
          controller: _defeitoController,
          label: OficinaStrings.relatoDoProblema,
          icon: Icons.report_problem,
        ),
        _buildTextField(
          controller: _descricaoServicoController,
          label: OficinaStrings.descricaoDoServicoRealizado,
          icon: Icons.description,
          maxLines: 3,
        ),
        _buildTextField(
          controller: _valorTotalController,
          label: OficinaStrings.valorEstimadoDoServico,
          icon: Icons.monetization_on,
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  Widget _buildDropdownClientes() {
    return _buildDropdownField<int>(
      label: OficinaStrings.selecionarCliente,
      value: _selectedClienteId,
      icon: Icons.person_search,
      items: _clientesCadastrados
          .map((c) => DropdownMenuItem(value: c.id, child: Text(c.nome)))
          .toList(),
      onChanged: (value) {
        setState(() {
          _selectedClienteId = value;
          _selectedCarroId = null;
          _carrosDoCliente = [];
          if (value != null) _bloc.add(CarregarDadosClienteCompletoEvent(value));
        });
      },
      validator: (value) =>
          !_isClienteNovo && value == null ? OficinaStrings.selecioneUmCliente : null,
    );
  }

  Widget _buildDropdownCarros() {
    if (_isClienteNovo) return const SizedBox.shrink();
    return _buildDropdownField<int>(
      label: OficinaStrings.dadosDoVeiculo,
      value: _selectedCarroId,
      icon: Icons.directions_car_filled_outlined,
      items: _carrosDoCliente
          .map((c) => DropdownMenuItem(value: c.id, child: Text('${c.modelo} (${c.placa})')))
          .toList(),
      onChanged: (value) {
        setState(() {
          _selectedCarroId = value;
          final carro = _carrosDoCliente.firstWhere((c) => c.id == value);
          _placaController.text = carro.placa;
          _carroModeloController.text = carro.modelo;
        });
      },
      validator: (value) => !_isClienteNovo && value == null ? OficinaStrings.dadosDoVeiculo : null,
    );
  }

  Widget _buildSubmitButton(bool isLoading) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : _enviarFormulario,
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(OficinaStrings.finalizarOrdemDeServico.toUpperCase()),
      ),
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required T? value,
    required IconData icon,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    String? Function(T?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: DropdownButtonFormField<T>(
        value: value,
        dropdownColor: ColorsApp.preto,
        style: const TextStyle(color: ColorsApp.branco),
        decoration: _getInputDecoration(label, icon),
        items: items,
        onChanged: onChanged,
        validator: validator,
      ),
    );
  }

  InputDecoration _getInputDecoration(String label, IconData icon, {bool enabled = true}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white60),
      prefixIcon: Icon(icon, color: enabled ? ColorsApp.azulClaro : Colors.white24, size: 22),
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: ColorsApp.azulClaro, width: 2),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: TextStyle(color: enabled ? ColorsApp.branco : Colors.white24),
        decoration: _getInputDecoration(label, icon, enabled: enabled),
        validator: (value) =>
            enabled && (value == null || value.isEmpty) ? OficinaStrings.obrigatorio : null,
      ),
    );
  }
}
