import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:oficina_conectada_front/constants/colors.dart';
import 'package:oficina_conectada_front/widgets/toast/custom_toast.dart';
import 'package:oficina_conectada_front/controllers/ordem_de_servico/adicionar_ordem_controller.dart';
import 'package:oficina_conectada_front/controllers/ordem_de_servico/adicionar_ordem_event.dart';
import 'package:oficina_conectada_front/controllers/ordem_de_servico/adicionar_ordem_state.dart';

class EditarOrdemView extends StatefulWidget {
  const EditarOrdemView({super.key});

  @override
  State<EditarOrdemView> createState() => _EditarOrdemViewState();
}

class _EditarOrdemViewState extends State<EditarOrdemView> {
  final _formKey = GlobalKey<FormState>();

  final _nomeController = TextEditingController();
  final _cpfController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _emailController = TextEditingController();

  final _modeloController = TextEditingController();
  final _placaController = TextEditingController();
  final _anoController = TextEditingController();
  final _corController = TextEditingController();
  final _marcaController = TextEditingController();

  final _cpfMask = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {'#': RegExp(r'[0-9]')},
  );

  final _telefoneMask = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {'#': RegExp(r'[0-9]')},
  );

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
    _marcaController.dispose();
    super.dispose();
  }

  void _cadastrarTudo() {
    if (_formKey.currentState?.validate() ?? false) {
      final dadosCadastro = {
        'nome': _nomeController.text,
        'cpf': _cpfController.text,
        'telefone': _telefoneController.text,
        'email': _emailController.text,
        'placa': _placaController.text,
        'modelo': _modeloController.text,
        'marca': _marcaController.text,
        'ano': _anoController.text,
        'cor': _corController.text,
      };

      context.read<AdicionarOrdemController>().add(
        CadastrarNovoClienteECarroEvent(dadosCadastro),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AdicionarOrdemController, AdicionarOrdemState>(
      listener: (context, state) {
        if (state is CadastrarClienteSuccessState) {
          Navigator.pop(context, true);
        } else if (state is CadastrarClienteErrorState) {
          CustomToast.show(context, message: state.message, type: ToastType.error);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: ColorsApp.bgDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ColorsApp.branco.withOpacity(0.1)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            const Divider(height: 1, color: Colors.white10),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('DADOS PESSOAIS'),
                      _buildField(
                        _nomeController,
                        'Nome Completo',
                        placeholder: 'Ex: José da Silva',
                        capitalization: TextCapitalization.words,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: _buildField(
                              _cpfController,
                              'CPF',
                              placeholder: '000.000.000-00',
                              keyboard: TextInputType.number,
                              formatters: [_cpfMask],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildField(
                              _telefoneController,
                              'Telefone',
                              placeholder: '(00) 00000-0000',
                              keyboard: TextInputType.phone,
                              formatters: [_telefoneMask],
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: _buildField(
                              _emailController,
                              'E-mail',
                              placeholder: 'email@exemplo.com',
                              keyboard: TextInputType.emailAddress,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(child: SizedBox()),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Divider(height: 1, color: Colors.white10),
                      const SizedBox(height: 24),
                      _buildSectionTitle('VEÍCULO'),
                      Row(
                        children: [
                          Expanded(
                            child: _buildField(
                              _marcaController,
                              'Marca',
                              placeholder: 'Ex: Honda',
                              capitalization: TextCapitalization.words,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildField(
                              _modeloController,
                              'Modelo',
                              placeholder: 'Ex: Civic',
                              capitalization: TextCapitalization.words,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildField(
                              _placaController,
                              'Placa',
                              placeholder: 'EX: ABC-1D23',
                              keyboard: TextInputType.text,
                              capitalization: TextCapitalization.characters,
                              formatters: [UpperCaseTextFormatter()],
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: _buildField(
                              _anoController,
                              'Ano',
                              placeholder: 'EX: 2024',
                              keyboard: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildField(
                              _corController,
                              'Cor',
                              placeholder: 'Ex: Prata',
                            ),
                          ),
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
              const Icon(
                Icons.person_add_alt_1,
                color: ColorsApp.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Cadastrar Novo Cliente',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
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
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label, {
    String? placeholder,
    TextInputType keyboard = TextInputType.text,
    List<TextInputFormatter>? formatters,
    TextCapitalization capitalization = TextCapitalization.none,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            keyboardType: keyboard,
            inputFormatters: formatters,
            textCapitalization: capitalization,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: const TextStyle(color: Colors.white24),
              filled: true,
              fillColor: ColorsApp.cardDark,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: ColorsApp.branco.withOpacity(0.1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: ColorsApp.primaryColor,
                  width: 1.5,
                ),
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
                side: BorderSide(color: ColorsApp.branco.withOpacity(0.1)),
              ),
            ),
            child: const Text('Cancelar', style: TextStyle(fontWeight: FontWeight.w500)),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: _cadastrarTudo,
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorsApp.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            icon: const Icon(Icons.person_add, size: 18),
            label: const Text(
              'Cadastrar e Selecionar',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
