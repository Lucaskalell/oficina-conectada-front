import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:oficina_conectada_front/core/constants/app_colors.dart';
import 'package:oficina_conectada_front/models/mecanico_model.dart';
import 'package:oficina_conectada_front/modules/mecanicos/mecanicos_bloc.dart';
import 'package:oficina_conectada_front/modules/mecanicos/mecanicos_event.dart';
import 'package:oficina_conectada_front/modules/mecanicos/mecanicos_service.dart';
import 'package:oficina_conectada_front/modules/mecanicos/mecanicos_state.dart';
import 'package:oficina_conectada_front/shared/widgets/custom_toast/custom_toast.dart';

class MecanicosPage extends StatefulWidget {
  const MecanicosPage({super.key});

  @override
  State<MecanicosPage> createState() => _MecanicosPageState();
}

class _MecanicosPageState extends State<MecanicosPage> {
  late MecanicosBloc _mecanicosBloc;
  late MecanicosService _mecanicosService;
  late TextEditingController _nomeController;
  late TextEditingController _especialidadeController;
  late TextEditingController _telefoneController;
  late TextEditingController _emailController;
  late TextEditingController _senhaController;

  String _textoBusca = '';
  MecanicoModel? _mecanicoEmEdicao;
  bool _ativoNoFormulario = true;
  final _mascaraTelefone = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {'#': RegExp(r'[0-9]')},
  );

  String _iniciais(String nome) {
    if (nome.isEmpty) return '??';
    final partes = nome.trim().split(' ');
    if (partes.length >= 2)
      return '${partes.first[0]}${partes.last[0]}'.toUpperCase();
    return partes.first
        .substring(0, partes.first.length > 1 ? 2 : 1)
        .toUpperCase();
  }

  void _limparFormulario() {
    _nomeController.clear();
    _especialidadeController.clear();
    _telefoneController.clear();
    _emailController.clear();
    _senhaController.clear();
    _mecanicoEmEdicao = null;
    _ativoNoFormulario = true;
  }

  void _abrirModalNovoMecanico() {
    _limparFormulario();
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: _construirModalMecanico(ctx, editando: false),
        ),
      ),
    );
  }

  void _abrirModalEdicao(MecanicoModel mecanico) {
    _mecanicoEmEdicao = mecanico;
    _nomeController.text = mecanico.nome;
    _especialidadeController.text = mecanico.especialidade ?? '';
    _telefoneController.text = mecanico.telefone ?? '';
    _ativoNoFormulario = mecanico.ativo;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: _construirModalMecanico(
              ctx,
              editando: true,
              setModalState: setModalState,
            ),
          ),
        ),
      ),
    );
  }

  void _enviarFormulario(BuildContext ctx) {
    if (_nomeController.text.isEmpty) {
      CustomToast.show(
        context,
        message: 'O nome é obrigatório',
        type: ToastType.atencao,
      );
      return;
    }

    if (_mecanicoEmEdicao != null) {
      final dados = MecanicoModel(
        nome: _nomeController.text,
        especialidade: _especialidadeController.text,
        telefone: _telefoneController.text,
        ativo: _ativoNoFormulario,
      );
      _mecanicosBloc.add(AtualizarMecanico(_mecanicoEmEdicao!.id!, dados));
    } else {
      if (_emailController.text.isEmpty || _senhaController.text.isEmpty) {
        CustomToast.show(
          context,
          message: 'E-mail e senha são obrigatórios',
          type: ToastType.atencao,
        );
        return;
      }
      final mecanico = MecanicoModel(
        nome: _nomeController.text,
        especialidade: _especialidadeController.text,
        telefone: _telefoneController.text,
        email: _emailController.text,
        senha: _senhaController.text,
      );
      _mecanicosBloc.add(CriarMecanico(mecanico));
    }

    Navigator.pop(ctx);
  }

  Future<void> _confirmarDesativacao(MecanicoModel mecanico) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.fundoCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.borda),
        ),
        title: const Text(
          'Desativar Mecânico',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        content: Text(
          'Tem certeza que deseja desativar "${mecanico.nome}"? O acesso dele ao sistema será bloqueado.',
          style: const TextStyle(color: Colors.white54, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.erro,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Desativar'),
          ),
        ],
      ),
    );
    if (confirmado == true) {
      _mecanicosBloc.add(DesativarMecanico(mecanico.id!));
    }
  }

  @override
  void initState() {
    super.initState();
    _mecanicosService = MecanicosService();
    _mecanicosBloc = MecanicosBloc(_mecanicosService);
    _nomeController = TextEditingController();
    _especialidadeController = TextEditingController();
    _telefoneController = TextEditingController();
    _emailController = TextEditingController();
    _senhaController = TextEditingController();
    _mecanicosBloc.add(CarregarMecanicos());
  }

  Widget _construirHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mecânicos',
                style: TextStyle(
                  color: AppColors.textoPrincipal,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Equipe da oficina e acesso ao sistema',
                style: TextStyle(
                  color: AppColors.textoSecundario,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          ElevatedButton.icon(
            onPressed: _abrirModalNovoMecanico,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaria,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(Icons.add, size: 16),
            label: const Text(
              'Novo Mecânico',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirBusca() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: 350,
        child: TextField(
          onChanged: (v) => setState(() => _textoBusca = v),
          style: const TextStyle(color: AppColors.textoPrincipal, fontSize: 13),
          decoration: InputDecoration(
            hintText: 'Buscar por nome ou especialidade...',
            hintStyle: const TextStyle(color: AppColors.textoSecundario),
            prefixIcon: const Icon(
              Icons.search,
              color: AppColors.textoSecundario,
              size: 16,
            ),
            filled: true,
            fillColor: AppColors.fundoCard,
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
    );
  }

  Widget _construirGrade(List<MecanicoModel> mecanicos) {
    if (mecanicos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.fundoCard,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.build_outlined,
                color: Colors.white24,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Nenhum mecânico encontrado',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tente ajustar a busca ou cadastre um novo mecânico.',
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
      );
    }

    final largura = MediaQuery.of(context).size.width;
    final colunas = largura > 1200
        ? 3
        : largura > 800
        ? 2
        : 1;

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: colunas,
        mainAxisExtent: 190,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: mecanicos.length,
      itemBuilder: (context, index) => _construirCardMecanico(mecanicos[index]),
    );
  }

  Widget _construirCardMecanico(MecanicoModel mecanico) {
    final corStatus = mecanico.ativo
        ? AppColors.sucesso
        : AppColors.textoSecundario;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.fundoCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borda),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.primaria.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _iniciais(mecanico.nome),
                      style: const TextStyle(
                        color: AppColors.primaria,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mecanico.nome,
                        style: const TextStyle(
                          color: AppColors.textoPrincipal,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        mecanico.especialidade?.isNotEmpty == true
                            ? mecanico.especialidade!
                            : 'Sem especialidade',
                        style: const TextStyle(
                          color: AppColors.textoSecundario,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_horiz,
                  color: AppColors.textoSecundario,
                  size: 20,
                ),
                color: AppColors.fundoCard,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: AppColors.borda),
                ),
                onSelected: (value) {
                  if (value == 'editar') {
                    _abrirModalEdicao(mecanico);
                  } else if (value == 'desativar') {
                    _confirmarDesativacao(mecanico);
                  }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'editar',
                    child: Text(
                      'Editar',
                      style: TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ),
                  if (mecanico.ativo)
                    const PopupMenuItem(
                      value: 'desativar',
                      child: Text(
                        'Desativar',
                        style: TextStyle(color: Colors.redAccent, fontSize: 13),
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _construirInfoMecanico(
            Icons.phone_outlined,
            mecanico.telefone ?? 'Não informado',
          ),
          const SizedBox(height: 6),
          _construirInfoMecanico(
            Icons.email_outlined,
            mecanico.email ?? 'Não informado',
          ),
          const Spacer(),
          Divider(color: AppColors.borda, height: 1),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: corStatus,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                mecanico.ativo ? 'Ativo' : 'Inativo',
                style: TextStyle(
                  color: corStatus,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _construirInfoMecanico(IconData icone, String texto) {
    return Row(
      children: [
        Icon(icone, color: AppColors.textoSecundario, size: 14),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            texto,
            style: const TextStyle(
              color: AppColors.textoSecundario,
              fontSize: 12,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _construirModalMecanico(
    BuildContext ctx, {
    required bool editando,
    StateSetter? setModalState,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.fundoCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borda),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      editando ? 'Editar Mecânico' : 'Novo Mecânico',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      editando
                          ? 'Atualize os dados do mecânico.'
                          : 'Cadastre um mecânico e crie o acesso dele ao sistema.',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white54),
                  onPressed: () => Navigator.pop(ctx),
                  splashRadius: 20,
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.white10),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _construirLabel('Nome Completo'),
                  _construirCampo(
                    _nomeController,
                    'Nome do mecânico',
                    capitalizacao: TextCapitalization.words,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _construirLabel('Especialidade'),
                            _construirCampo(
                              _especialidadeController,
                              'Ex: Suspensão',
                              capitalizacao: TextCapitalization.words,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _construirLabel('Telefone'),
                            _construirCampo(
                              _telefoneController,
                              '(00) 00000-0000',
                              teclado: TextInputType.phone,
                              formatadores: [_mascaraTelefone],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (!editando) ...[
                    const SizedBox(height: 24),
                    const Divider(height: 1, color: Colors.white10),
                    const SizedBox(height: 16),
                    const Text(
                      'Acesso ao Sistema',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _construirLabel('E-mail'),
                    _construirCampo(
                      _emailController,
                      'email@exemplo.com',
                      teclado: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    _construirLabel('Senha Provisória'),
                    _construirCampo(
                      _senhaController,
                      'Senha para o primeiro acesso',
                      ocultar: true,
                    ),
                  ],
                  if (editando) ...[
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Mecânico ativo',
                          style: TextStyle(color: Colors.white, fontSize: 13),
                        ),
                        Switch(
                          value: _ativoNoFormulario,
                          activeThumbColor: AppColors.primaria,
                          onChanged: (v) => (setModalState ?? setState)(
                            () => _ativoNoFormulario = v,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          const Divider(height: 1, color: Colors.white10),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => _enviarFormulario(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaria,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    editando ? 'Salvar' : 'Cadastrar',
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

  Widget _construirLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.textoPrincipal,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _construirCampo(
    TextEditingController controller,
    String hint, {
    TextInputType teclado = TextInputType.text,
    List<TextInputFormatter>? formatadores,
    TextCapitalization capitalizacao = TextCapitalization.none,
    bool ocultar = false,
  }) {
    return SizedBox(
      height: 40,
      child: TextField(
        controller: controller,
        keyboardType: teclado,
        inputFormatters: formatadores,
        textCapitalization: capitalizacao,
        obscureText: ocultar,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white24),
          filled: true,
          fillColor: AppColors.fundoPrincipal,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 0,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: AppColors.borda),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: AppColors.primaria),
          ),
        ),
      ),
    );
  }

  Widget _blocBuilder() {
    return BlocConsumer<MecanicosBloc, MecanicosState>(
      bloc: _mecanicosBloc,
      listener: (context, estado) {
        if (estado is MecanicosErro) {
          CustomToast.show(
            context,
            message: estado.mensagem,
            type: ToastType.erro,
          );
        }
        if (estado is MecanicoSalvo) {
          CustomToast.show(
            context,
            message: estado.mensagem,
            type: ToastType.sucesso,
          );
        }
      },
      builder: (context, estado) {
        List<MecanicoModel> mecanicos = [];
        if (estado is MecanicosCarregados) {
          mecanicos = estado.mecanicos;
        }

        final mecanicosFiltrados = mecanicos.where((m) {
          final busca = _textoBusca.toLowerCase();
          return m.nome.toLowerCase().contains(busca) ||
              (m.especialidade ?? '').toLowerCase().contains(busca);
        }).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _construirHeader(),
            _construirBusca(),
            const SizedBox(height: 16),
            Expanded(
              child: estado is MecanicosCarregando && mecanicos.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaria,
                      ),
                    )
                  : _construirGrade(mecanicosFiltrados),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fundoPrincipal,
      body: _blocBuilder(),
    );
  }

  @override
  void dispose() {
    _mecanicosBloc.close();
    _nomeController.dispose();
    _especialidadeController.dispose();
    _telefoneController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }
}
