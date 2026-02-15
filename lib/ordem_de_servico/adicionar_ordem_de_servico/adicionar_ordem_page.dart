import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oficina_conectada_front/colors/colors.dart';
import 'package:oficina_conectada_front/model/add_ordem_de_servico/ordem_de_servico_model.dart';

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
  final _clienteController = TextEditingController();
  final _carroController = TextEditingController();
  final _defeitoController = TextEditingController();
  final _descricaoServicoController = TextEditingController();
  final _valorTotalController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _bloc = AdicionarOrdemDeServicoBloc(OrdemDeServicoRepository());
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('Nova Ordem de Serviço'),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: const TextStyle(color: ColorsApp.branco, fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white60),
          prefixIcon: Icon(icon, color: ColorsApp.azulClaro, size: 22),
          filled: true,
          fillColor: Colors.white.withOpacity(0.05),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: ColorsApp.azulClaro, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.redAccent),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.redAccent, width: 2),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Por favor, informe o campo $label';
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
            _sectionTitle('Informações do Cliente'),
            _buildTextField(
              controller: _clienteController,
              label: 'Nome do Cliente',
              icon: Icons.person_outline,
            ),
            
            _sectionTitle('Dados do Veículo'),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildTextField(
                    controller: _carroController,
                    label: 'Modelo do Carro',
                    icon: Icons.directions_car_filled_outlined,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: _buildTextField(
                    controller: _placaController,
                    label: 'Placa',
                    icon: Icons.pin_outlined,
                  ),
                ),
              ],
            ),

            _sectionTitle('Detalhes do Serviço'),
            _buildTextField(
              controller: _defeitoController,
              label: 'Relato do Problema',
              icon: Icons.report_problem_outlined,
            ),
            _buildTextField(
              controller: _descricaoServicoController,
              label: 'Descrição do Serviço Realizado',
              icon: Icons.description_outlined,
              maxLines: 3,
            ),
            _buildTextField(
              controller: _valorTotalController,
              label: 'Valor Estimado do Serviço',
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
        boxShadow: [
          if (!isLoading)
            BoxShadow(
              color: ColorsApp.verde.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: isLoading ? null : _enviarFormulario,
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
              )
            : const Text(
                'FINALIZAR ORDEM',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
      ),
    );
  }

  void _enviarFormulario() {
    if (_formKey.currentState?.validate() ?? false) {
      final novaOrdem = OrdemDeServicoModel(
        cliente: _clienteController.text,
        carro: _carroController.text,
        placa: _placaController.text,
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ordem criada com sucesso!'),
              backgroundColor: ColorsApp.verdeEscuro,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pop(context);
        }
        if (state is AdicionarOrdemErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro: ${state.message}'),
              backgroundColor: ColorsApp.vermelho,
              behavior: SnackBarBehavior.floating,
            ),
          );
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

  @override
  void dispose() {
    _bloc.close();
    _placaController.dispose();
    _clienteController.dispose();
    _carroController.dispose();
    _defeitoController.dispose();
    _descricaoServicoController.dispose();
    _valorTotalController.dispose();
    super.dispose();
  }
}
