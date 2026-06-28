import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:oficina_conectada_front/core/constants/app_colors.dart';
import 'package:oficina_conectada_front/modules/ordens/adicionar_ordem/adicionar_ordem_bloc.dart';
import 'package:oficina_conectada_front/modules/ordens/adicionar_ordem/adicionar_ordem_event.dart';
import 'package:oficina_conectada_front/modules/ordens/adicionar_ordem/adicionar_ordem_state.dart';
import 'package:oficina_conectada_front/shared/widgets/custom_toast/custom_toast.dart';

class CadastrarClientePage extends StatefulWidget {
  const CadastrarClientePage({super.key});

  @override
  State<CadastrarClientePage> createState() => _CadastrarClientePageState();
}

class _CadastrarClientePageState extends State<CadastrarClientePage> {

// ========= BLOC / INSTÂNCIAS / CONTROLLERS =========

  late TextEditingController _nomeController;
  late TextEditingController _cpfController;
  late TextEditingController _telefoneController;
  late TextEditingController _emailController;
  late TextEditingController _modeloController;
  late TextEditingController _placaController;
  late TextEditingController _anoController;
  late TextEditingController _corController;
  late TextEditingController _marcaController;
  late GlobalKey<FormState> _formKey;

// ========= VARIÁVEIS =========

  final _mascaraCpf = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {'#': RegExp(r'[0-9]')},
  );
  final _mascaraTelefone = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {'#': RegExp(r'[0-9]')},
  );

// ========= FUNÇÕES =========

  void _cadastrarTudo() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    context.read<AdicionarOrdemBloc>().add(
          CadastrarClienteECarro({
            'nome': _nomeController.text,
            'cpf': _cpfController.text,
            'telefone': _telefoneController.text,
            'email': _emailController.text,
            'placa': _placaController.text,
            'modelo': _modeloController.text,
            'marca': _marcaController.text,
            'ano': _anoController.text,
            'cor': _corController.text,
          }),
        );
  }

// ========= INIT STATE =========

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController();
    _cpfController = TextEditingController();
    _telefoneController = TextEditingController();
    _emailController = TextEditingController();
    _modeloController = TextEditingController();
    _placaController = TextEditingController();
    _anoController = TextEditingController();
    _corController = TextEditingController();
    _marcaController = TextEditingController();
    _formKey = GlobalKey<FormState>();
  }

// ========= COMPONENTES DA TELA =========

  Widget _construirHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(
            children: [
              Icon(Icons.person_add_alt_1, color: AppColors.primaria, size: 20),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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

  Widget _construirTituloSecao(String titulo) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        titulo,
        style: const TextStyle(
          color: Colors.white54,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _construirCampo(
    TextEditingController controller,
    String label, {
    String? placeholder,
    TextInputType teclado = TextInputType.text,
    List<TextInputFormatter>? formatadores,
    TextCapitalization capitalizacao = TextCapitalization.none,
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
            keyboardType: teclado,
            inputFormatters: formatadores,
            textCapitalization: capitalizacao,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: const TextStyle(color: Colors.white24),
              filled: true,
              fillColor: AppColors.fundoCard,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.primaria, width: 1.5),
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

  Widget _construirRodape() {
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
                side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
              ),
            ),
            child: const Text('Cancelar', style: TextStyle(fontWeight: FontWeight.w500)),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: _cadastrarTudo,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaria,
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

// ========= BLOC BUILDER =========

  Widget _blocBuilder() {
    return BlocListener<AdicionarOrdemBloc, AdicionarOrdemState>(
      listener: (context, estado) {
        if (estado is CadastrarClienteSucesso) {
          Navigator.pop(context, true);
        }
        if (estado is CadastrarClienteErro) {
          CustomToast.show(context, message: estado.mensagem, type: ToastType.erro);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.fundoPrincipal,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _construirHeader(),
            const Divider(height: 1, color: Colors.white10),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _construirTituloSecao('DADOS PESSOAIS'),
                      _construirCampo(_nomeController, 'Nome Completo',
                          placeholder: 'Ex: José da Silva',
                          capitalizacao: TextCapitalization.words),
                      Row(
                        children: [
                          Expanded(
                            child: _construirCampo(_cpfController, 'CPF',
                                placeholder: '000.000.000-00',
                                teclado: TextInputType.number,
                                formatadores: [_mascaraCpf]),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _construirCampo(_telefoneController, 'Telefone',
                                placeholder: '(00) 00000-0000',
                                teclado: TextInputType.phone,
                                formatadores: [_mascaraTelefone]),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: _construirCampo(_emailController, 'E-mail',
                                placeholder: 'email@exemplo.com',
                                teclado: TextInputType.emailAddress),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(child: SizedBox()),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Divider(height: 1, color: Colors.white10),
                      const SizedBox(height: 24),
                      _construirTituloSecao('VEÍCULO'),
                      Row(
                        children: [
                          Expanded(
                            child: _construirCampo(_marcaController, 'Marca',
                                placeholder: 'Ex: Honda',
                                capitalizacao: TextCapitalization.words),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _construirCampo(_modeloController, 'Modelo',
                                placeholder: 'Ex: Civic',
                                capitalizacao: TextCapitalization.words),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _construirCampo(_placaController, 'Placa',
                                placeholder: 'EX: ABC-1D23',
                                capitalizacao: TextCapitalization.characters,
                                formatadores: [_UpperCaseFormatter()]),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: _construirCampo(_anoController, 'Ano',
                                placeholder: 'Ex: 2024', teclado: TextInputType.number),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _construirCampo(_corController, 'Cor',
                                placeholder: 'Ex: Prata'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Divider(height: 1, color: Colors.white10),
            _construirRodape(),
          ],
        ),
      ),
    );
  }

// ========= BUILD =========

  @override
  Widget build(BuildContext context) => _blocBuilder();

// ========= DISPOSE =========

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
}

class _UpperCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(text: newValue.text.toUpperCase(), selection: newValue.selection);
  }
}
