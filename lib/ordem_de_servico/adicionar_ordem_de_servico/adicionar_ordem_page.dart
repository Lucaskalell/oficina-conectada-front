import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oficina_conectada_front/colors/colors.dart';
import 'package:oficina_conectada_front/ordem_de_servico/model/ordem_de_servico_model.dart';

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
      title: const Text('Criar Ordem de Serviço'),
      backgroundColor: ColorsApp.preto,
      iconTheme: const IconThemeData(color: ColorsApp.branco),
      titleTextStyle: const TextStyle(color: ColorsApp.branco, fontSize: 20),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(color: ColorsApp.branco),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white70)),
          focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          errorBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.redAccent)),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Por favor, preencha o campo $label';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildBody(AdicionarOrdemState state) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildTextField(controller: _clienteController, label: 'Cliente'),
            _buildTextField(controller: _carroController, label: 'Carro'),
            _buildTextField(controller: _placaController, label: 'Placa'),
            _buildTextField(controller: _defeitoController, label: 'Defeito'),
            _buildTextField(controller: _descricaoServicoController, label: 'Descrição do Serviço'),
            _buildTextField(
              controller: _valorTotalController,
              label: 'Valor Total',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            _buildSubmitButton(state),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton(AdicionarOrdemState state) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          padding: const EdgeInsets.symmetric(vertical: 15),
        ),
        onPressed: state is AdiconaroOrdemLoadingState ? null : _enviarFormulario,
        child: state is AdiconaroOrdemLoadingState
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : const Text('SALVAR ORDEM', style: TextStyle(color: Colors.white, fontSize: 16)),
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
            const SnackBar(content: Text('Salvo com sucesso!'), backgroundColor: Colors.green),
          );
          Navigator.pop(context);
        }
        if (state is AdicionarOrdemErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
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
