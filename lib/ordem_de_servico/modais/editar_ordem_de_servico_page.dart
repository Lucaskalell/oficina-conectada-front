import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oficina_conectada_front/colors/colors.dart';
import 'package:oficina_conectada_front/model/add_ordem_de_servico/ordem_de_servico_model.dart';
import 'package:oficina_conectada_front/enum/enum_ordem_de_servico.dart';
import '../adicionar_ordem_de_servico/adicionar_ordem_bloc.dart';
import '../adicionar_ordem_de_servico/adicionar_ordem_event.dart';

class EditarOrdemDeServicoPage extends StatefulWidget {
  const EditarOrdemDeServicoPage({super.key});

  @override
  State<EditarOrdemDeServicoPage> createState() => _EditarOrdemDeServicoPageState();
}

class _EditarOrdemDeServicoPageState extends State<EditarOrdemDeServicoPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers Pessoais
  final _nomeController = TextEditingController();
  final _cpfController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _emailController = TextEditingController();

  // Controllers Veículo
  final _modeloController = TextEditingController();
  final _placaController = TextEditingController();
  final _anoController = TextEditingController();
  final _corController = TextEditingController();

  @override
  void dispose() {
    _nomeController.dispose();
    _cpfController.dispose();
    _telefoneController.dispose();
    _emailController.dispose();
    _modeloController.dispose();
    _placaController.dispose();
    _anoController.dispose();
    _corController.dispose();
    super.dispose();
  }

  void _cadastrarTudo() {
    if (_formKey.currentState?.validate() ?? false) {
      // 1. Monta o mapa de cadastro
      final dadosCadastro = {
        'nome': _nomeController.text,
        'cpf': _cpfController.text,
        'telefone': _telefoneController.text,
        'email': _emailController.text,
        'placa': _placaController.text,
        'modelo': _modeloController.text,
        'ano': _anoController.text,
        'cor': _corController.text,
      };

      // 2. Monta o model da OS (vazia por enquanto, a lógica da página principal preenche o serviço)
      final novaOrdem = OrdemDeServicoModel(
        defeito: '', // Será preenchido na tela principal
        valorTotal: 0.0,
        status: StatusOrdemDeServico.EM_ANDAMENTO,
      );

      // 3. Dispara o evento
      context.read<AdicionarOrdemDeServicoBloc>().add(
        CriarOSComNovoClienteEvent(dadosCadastro, novaOrdem),
      );

      Navigator.pop(context, true); // Retorna true para avisar que cadastrou
    }
  }

  @override
  Widget build(BuildContext context) {
    // Fundo do modal igual ao print da Vercel (escuro, bordas arredondadas)
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF09090B), // Zinc 950 - Padrão escuro Vercel
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          const Divider(height: 1, color: Colors.white10),

          // Corpo rolável do formulário
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('DADOS PESSOAIS'),
                    _buildField(_nomeController, 'Nome Completo', placeholder: 'Ex: José da Silva'),
                    Row(
                      children: [
                        Expanded(child: _buildField(_cpfController, 'CPF', placeholder: '000.000.000-00', keyboard: TextInputType.number)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildField(_telefoneController, 'Telefone', placeholder: '(00) 00000-0000', keyboard: TextInputType.phone)),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(child: _buildField(_emailController, 'E-mail', placeholder: 'email@exemplo.com', keyboard: TextInputType.emailAddress)),
                        const SizedBox(width: 16),
                        Expanded(child: const SizedBox()), // Espaço vazio para manter o grid igual ao React
                      ],
                    ),

                    const SizedBox(height: 24),
                    const Divider(height: 1, color: Colors.white10),
                    const SizedBox(height: 24),

                    _buildSectionTitle('VEÍCULO'),
                    Row(
                      children: [
                        Expanded(child: _buildField(_modeloController, 'Modelo', placeholder: 'Ex: Honda Civic')),
                        const SizedBox(width: 16),
                        Expanded(child: _buildField(_placaController, 'Placa', placeholder: 'ABC-1D23')),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(child: _buildField(_anoController, 'Ano', placeholder: '2024', keyboard: TextInputType.number)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildField(_corController, 'Cor', placeholder: 'Ex: Prata')),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          const Divider(height: 1, color: Colors.white10),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.person_add_alt_1, color: Color(0xFF10B981), size: 20), // Ícone verde
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Cadastrar Novo Cliente',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Preencha os dados do cliente e do veículo para continuar.',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Colors.white54, size: 20),
            splashRadius: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
            color: Colors.white54,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2
        ),
      ),
    );
  }

  Widget _buildField(
      TextEditingController controller,
      String label, {
        String? placeholder,
        TextInputType keyboard = TextInputType.text,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            keyboardType: keyboard,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: const TextStyle(color: Colors.white24),
              filled: true,
              fillColor: const Color(0xFF18181B), // Zinc 900
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF10B981), width: 1.5), // Borda verde no focus
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.redAccent),
              ),
            ),
            validator: (v) => v == null || v.isEmpty ? 'Obrigatório' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
            ),
            child: const Text('Cancelar', style: TextStyle(fontWeight: FontWeight.w500)),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: _cadastrarTudo,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981), // Verde Vercel
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            icon: const Icon(Icons.person_add, size: 18),
            label: const Text('Cadastrar e Selecionar', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}