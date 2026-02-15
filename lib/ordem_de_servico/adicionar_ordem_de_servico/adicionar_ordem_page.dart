
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oficina_conectada_front/colors/colors.dart';
import 'package:oficina_conectada_front/model/add_ordem_de_servico/ordem_de_servico_model.dart';
import 'package:oficina_conectada_front/model/cliente_model.dart';
import 'package:oficina_conectada_front/strings/oficina_strings.dart';

import '../../components/toast/custom_toast.dart';
import '../../model/carro_model.dart';
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
  final _carroController = TextEditingController();
  final _defeitoController = TextEditingController();
  final _descricaoServicoController = TextEditingController();
  final _valorTotalController = TextEditingController();

  bool _isClienteNovo = false;
  List<ClienteModel> _clientesCadastrados = [];
  List<CarroModel> _carrosDoCliente = []; // No futuro>
  int? _selectedClienteId;
  int? _selectedCarroId; // No futuro, buscar carros do cliente selecionado

  @override
  void initState() {
    super.initState();
    _bloc = AdicionarOrdemDeServicoBloc(OrdemDeServicoRepository());
    _carregarClientes();
  }

  void _carregarClientes() async {
    try {
      final clientes = await OrdemDeServicoRepository().getClientes();
      setState(() {
        _clientesCadastrados = clientes;
      });
    } catch (e) {
      debugPrint('Erro ao carregar clientes: $e');
    }
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text(OficinaStrings.novaOrdemDeServico),
      centerTitle: true,
      elevation: 0,
      backgroundColor: ColorsApp.preto,
      iconTheme: const IconThemeData(color: ColorsApp.branco),
      titleTextStyle: const TextStyle(
        color: ColorsApp.branco,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildDropdownClientes() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: DropdownButtonFormField<int>(
        value: _selectedClienteId,
        dropdownColor: ColorsApp.preto,
        style: const TextStyle(color: ColorsApp.branco),
        decoration: InputDecoration(
          labelText: OficinaStrings.selecionarCliente,
          labelStyle: const TextStyle(color: Colors.white60),
          prefixIcon: const Icon(Icons.person_search, color: ColorsApp.azulClaro),
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
        ),
        items: _clientesCadastrados.map((cliente) {
          return DropdownMenuItem<int>(
            value: cliente.id,
            child: Text(cliente.nome),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedClienteId = value;
            // Aqui você poderia buscar os carros desse cliente para preencher outro dropdown
          });
        },
        validator: (value) => !_isClienteNovo && value == null ? OficinaStrings.selecioneUmCliente : null,
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
        style: TextStyle(color: enabled ? ColorsApp.branco : Colors.white24, fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white60),
          prefixIcon: Icon(icon, color: enabled ? ColorsApp.azulClaro : Colors.white24, size: 22),
          filled: true,
          fillColor: Colors.white.withOpacity(0.05),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: ColorsApp.azulClaro, width: 2),
          ),
        ),
        validator: (value) {
          if (enabled && (value == null || value.isEmpty)) {
            return OficinaStrings.porFavorInformeUmCampo.replaceAll('{campo}', label);
          }
          return null;
        },
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: ColorsApp.azulClaro,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildBody(AdicionarOrdemState state) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _sectionTitle(OficinaStrings.informacoesDoCliente),
                Row(
                  children: [
                    const Text(OficinaStrings.novoCliente, style: TextStyle(color: Colors.white70, fontSize: 12)),
                    Checkbox(
                      checkColor: ColorsApp.azulEscuro,
                      value: _isClienteNovo,
                      activeColor: ColorsApp.verdeClaro,
                      onChanged: (val) {
                        setState(() {
                          _isClienteNovo = val ?? false;
                          if (_isClienteNovo) _selectedClienteId = null;
                        });
                      },
                    ),
                  ],
                )
              ],
            ),
            
            _isClienteNovo 
              ? _buildTextField(
                  controller: _clienteNomeController,
                  label: OficinaStrings.nomeDoNovoCliente,
                  icon: Icons.person_add_alt_1_outlined,
                )
              : _buildDropdownClientes(),
            
            _sectionTitle(OficinaStrings.dadosDoVeiculo),
            // TODO: No futuro, se for cliente antigo, buscar dropdown de carros dele
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildTextField(
                    controller: _carroController,
                    label: OficinaStrings.modeloDoCarro,
                    icon: Icons.directions_car_filled_outlined,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: _buildTextField(
                    controller: _placaController,
                    label: OficinaStrings.placaDoCarro,
                    icon: Icons.pin_outlined,
                  ),
                ),
              ],
            ),

            _sectionTitle(OficinaStrings.detalhesDoServico),
            _buildTextField(
              controller: _defeitoController,
              label: OficinaStrings.relatoDoProblema,
              icon: Icons.report_problem_outlined,
            ),
            _buildTextField(
              controller: _descricaoServicoController,
              label: OficinaStrings.descricaoDoServicoRealizado,
              icon: Icons.description_outlined,
              maxLines: 3,
            ),
            _buildTextField(
              controller: _valorTotalController,
              label: OficinaStrings.valorEstimadoDoServico,
              icon: Icons.monetization_on_outlined,
              keyboardType: TextInputType.number,
            ),
            
            const SizedBox(height: 32),
            _buildSubmitButton(state),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton(AdicionarOrdemState state) {
    final isLoading = state is AdiconaroOrdemLoadingState;

    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: isLoading 
            ? [ColorsApp.verdeEscuro, ColorsApp.verde]
            : [ColorsApp.verde, ColorsApp.verdeEscuro],
        ),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: isLoading ? null : _enviarFormulario,
        child: isLoading
            ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white))
            : const Text(OficinaStrings.finalizarOrdemDeServico, style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _enviarFormulario() {
    if (_formKey.currentState?.validate() ?? false) {
      
      if (_isClienteNovo) {
        // Lógica para criar cliente novo primeiro ou enviar Super DTO
        // Por enquanto, vamos focar no envio da OS para cliente existente
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Funcionalidade de Novo Cliente em implementação no Service'))
        );
        return;
      }

      final novaOrdem = OrdemDeServicoModel(
        clienteId: _selectedClienteId,
        carroId: 1, // Mock por enquanto, ideal é selecionar o carro do cliente
        defeito: _defeitoController.text,
        descricaoServico: _descricaoServicoController.text,
        valorTotal: double.tryParse(_valorTotalController.text) ?? 0.0,
        entrada: DateTime.now(),
      );

      _bloc.add(CriarOrdemDeServico(novaOrdem));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AdicionarOrdemDeServicoBloc, AdicionarOrdemState>(
      bloc: _bloc,
        listener: (context, state) {
          if (state is AdicionarOrdemSuccessState) {
            CustomToast.show(
              context,
              message: OficinaStrings.ordemDeServicoCriadaComSucesso,
              type: ToastType.success,
            );
            Navigator.pop(context);
          }
        },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: ColorsApp.preto,
          appBar: _buildAppBar(),
          body: _buildBody(state),
        );
      },
    );
  }
}
