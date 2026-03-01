import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../colors/colors.dart';
import '../../components/card_tab_animated/card_tab_animated.dart';
import '../../enum/enum_ordem_de_servico.dart';
import '../../model/add_ordem_de_servico/ordem_de_servico_model.dart';
import '../adicionar_ordem_de_servico/adicionar_ordem_bloc.dart';
import '../adicionar_ordem_de_servico/adicionar_ordem_event.dart';

class EditarOrdemDeServicoPage extends StatefulWidget {
  const EditarOrdemDeServicoPage({super.key});

  @override
  State<EditarOrdemDeServicoPage> createState() => _EditarOrdemDeServicoPageState();
}

class _EditarOrdemDeServicoPageState extends State<EditarOrdemDeServicoPage> {
  final GlobalKey<CardTabAnimatedState> _cardTabKey = GlobalKey<CardTabAnimatedState>();

  // Forms para cada passo do cadastro
  final _formCliente = GlobalKey<FormState>();
  final _formCarro = GlobalKey<FormState>();
  final _formServico = GlobalKey<FormState>();

  // Controllers para capturar TUDO do novo cliente
  final _nomeController = TextEditingController();
  final _cpfController = TextEditingController(); // Opcional
  final _placaController = TextEditingController();
  final _modeloController = TextEditingController();
  final _defeitoController = TextEditingController();
  final _valorController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: const BoxDecoration(
        color: ColorsApp.preto,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          Flexible(
            child: CardTabAnimated(
              key: _cardTabKey,
              steps: [
                CardTabStep(
                  title: '1. Cliente',
                  content: SingleChildScrollView(child: _stepCliente()),
                  isStepValid: () => _formCliente.currentState?.validate() ?? false,
                ),
                CardTabStep(
                  title: '2. Veículo',
                  content: SingleChildScrollView(child: _stepVeiculo()),
                  isStepValid: () => _formCarro.currentState?.validate() ?? false,
                ),
                CardTabStep(
                  title: '3. Serviço',
                  content: SingleChildScrollView(child: _stepServico()),
                  isStepValid: () => _formServico.currentState?.validate() ?? false,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _stepCliente() {
    return Form(
      key: _formCliente,
      child: Column(
        children: [
          const Text(
            'CADASTRO DE NOVO CLIENTE',
            style: TextStyle(color: ColorsApp.azulClaro, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          _buildField(_nomeController, 'Nome Completo', Icons.person),
          _buildField(_cpfController, 'CPF', Icons.badge),
          const SizedBox(height: 15),
          _buildNextButton('PRÓXIMO: VEÍCULO', 0),
        ],
      ),
    );
  }

  Widget _stepVeiculo() {
    return Form(
      key: _formCarro,
      child: Column(
        children: [
          const Text(
            'DADOS DO VEÍCULO',
            style: TextStyle(color: ColorsApp.azulClaro, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          _buildField(_placaController, 'Placa', Icons.pin),
          _buildField(_modeloController, 'Modelo/Versão', Icons.directions_car),
          const SizedBox(height: 15),
          _buildNextButton('PRÓXIMO: PROBLEMA', 1),
        ],
      ),
    );
  }

  Widget _stepServico() {
    return Form(
      key: _formServico,
      child: Column(
        children: [
          const Text(
            'DETALHES DA ORDEM',
            style: TextStyle(color: ColorsApp.azulClaro, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          _buildField(_defeitoController, 'O que o cliente relatou?', Icons.build, maxLines: 2),
          _buildField(
            _valorController,
            'Valor Estimado',
            Icons.attach_money,
            keyboard: TextInputType.number,
          ),
          const SizedBox(height: 15),
          _buildFinalizeButton(),
        ],
      ),
    );
  }

  Widget _buildFinalizeButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: ColorsApp.branco),
        onPressed: () {
          if (_formServico.currentState!.validate()) {
            // 1. Monta o mapa de cadastro
            final dadosCadastro = {
              'nome': _nomeController.text,
              'placa': _placaController.text,
              'modelo': _modeloController.text,
            };

            // 2. Monta o model da OS
            final novaOrdem = OrdemDeServicoModel(
              defeito: _defeitoController.text,
              valorTotal: double.tryParse(_valorController.text) ?? 0.0,
              status: StatusOrdemDeServico.EM_ANDAMENTO,
            );

            // 3. Dispara o evento específico para Cliente Novo
            context.read<AdicionarOrdemDeServicoBloc>().add(
              CriarOSComNovoClienteEvent(dadosCadastro, novaOrdem),
            );

            Navigator.pop(context);
          }
        },
        child: const Text(
          'CADASTRAR TUDO',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // Helper para os campos de texto
  Widget _buildField(
    TextEditingController controller,
    String label,
    IconData icon, {
    int maxLines = 1,
    TextInputType keyboard = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboard,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: ColorsApp.branco),
          labelStyle: const TextStyle(color: Colors.white60),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
          ),
          focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: ColorsApp.branco)),
        ),
        validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
      ),
    );
  }

  Widget _buildNextButton(String text, int step) => SizedBox(
    width: double.infinity,
    height: 40,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: ColorsApp.branco),
      onPressed: () => _cardTabKey.currentState?.goToStep(step + 1),
      child: Text(text, style: const TextStyle(color: Colors.black)),
    ),
  );

  Widget _buildHeader() => Padding(
    padding: const EdgeInsets.all(16),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'NOVO CLIENTE & VEÍCULO',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close, color: Colors.white),
        ),
      ],
    ),
  );
}
