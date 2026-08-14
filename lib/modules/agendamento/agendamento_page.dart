import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oficina_conectada_front/core/constants/app_colors.dart';
import 'package:oficina_conectada_front/models/agendamento_model.dart';
import 'package:oficina_conectada_front/models/carro_model.dart';
import 'package:oficina_conectada_front/models/cliente_model.dart';
import 'package:oficina_conectada_front/models/mecanico_model.dart';
import 'package:oficina_conectada_front/modules/agendamento/agendamento_bloc.dart';
import 'package:oficina_conectada_front/modules/agendamento/agendamento_event.dart';
import 'package:oficina_conectada_front/modules/agendamento/agendamento_service.dart';
import 'package:oficina_conectada_front/modules/agendamento/agendamento_state.dart';
import 'package:oficina_conectada_front/shared/widgets/custom_date_range/calendario_dialog.dart';
import 'package:oficina_conectada_front/shared/widgets/custom_date_range/custom_date_range_field.dart';
import 'package:oficina_conectada_front/shared/widgets/custom_toast/custom_toast.dart';
import 'package:oficina_conectada_front/widgets/table_all/table_all.dart';

class AgendamentoPage extends StatefulWidget {
  const AgendamentoPage({super.key});

  @override
  State<AgendamentoPage> createState() => _AgendamentoPageState();
}

class _AgendamentoPageState extends State<AgendamentoPage> {

// ========= BLOC / INSTÂNCIAS / CONTROLLERS =========

  late AgendamentoBloc _agendamentoBloc;
  late AgendamentoService _agendamentoService;
  late TextEditingController _descricaoController;

// ========= VARIÁVEIS =========

  String _textoBusca = '';
  String? _filtroStatus;
  List<AgendamentoModel> _agendamentos = [];
  List<ClienteModel> _clientes = [];
  List<MecanicoModel> _mecanicos = [];
  ClienteModel? _clienteSelecionado;
  CarroModel? _carroSelecionado;
  MecanicoModel? _mecanicoSelecionado;
  DateTime? _dataHoraSelecionada;
  DateTime? _dataInicialFiltro;
  DateTime? _dataFinalFiltro;

// ========= FUNÇÕES =========

  String _formatarDataHora(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    final hora = data.hour.toString().padLeft(2, '0');
    final minuto = data.minute.toString().padLeft(2, '0');
    return '$dia/$mes/${data.year} $hora:$minuto';
  }

  Color _corPorStatus(String status) {
    switch (status) {
      case 'CONCLUIDO':
        return AppColors.concluido;
      case 'CANCELADO':
        return AppColors.erro;
      default:
        return AppColors.emAndamento;
    }
  }

  String _labelStatus(String status) {
    switch (status) {
      case 'CONCLUIDO':
        return 'Concluído';
      case 'CANCELADO':
        return 'Cancelado';
      default:
        return 'Agendado';
    }
  }

  void _aoAlterarDataInicialFiltro(DateTime? data) {
    setState(() => _dataInicialFiltro = data);
    _aplicarFiltroPeriodo();
  }

  void _aoAlterarDataFinalFiltro(DateTime? data) {
    setState(() => _dataFinalFiltro = data);
    _aplicarFiltroPeriodo();
  }

  void _aplicarFiltroPeriodo() {
    if (_dataInicialFiltro != null && _dataFinalFiltro != null) {
      _agendamentoBloc.add(CarregarAgendamentosPorPeriodo(_dataInicialFiltro!, _dataFinalFiltro!));
    }
  }

  void _limparFiltroPeriodo() {
    setState(() {
      _dataInicialFiltro = null;
      _dataFinalFiltro = null;
    });
    _agendamentoBloc.add(CarregarAgendamentos());
  }

  void _limparFormulario() {
    _descricaoController.clear();
    _clienteSelecionado = null;
    _carroSelecionado = null;
    _mecanicoSelecionado = null;
    _dataHoraSelecionada = null;
  }

  Future<void> _selecionarDataHora(StateSetter setModalState) async {
    final hoje = DateTime.now();
    final hojeSemHora = DateTime(hoje.year, hoje.month, hoje.day);

    final data = await showDialog<DateTime>(
      context: context,
      builder: (ctx) => CalendarioDialog(
        dataInicial: _dataHoraSelecionada ?? hojeSemHora,
        limiteMinimo: hojeSemHora,
        limiteMaximo: DateTime(hoje.year + 2, hoje.month, hoje.day),
      ),
    );
    if (data == null || !mounted) return;

    final hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dataHoraSelecionada ?? DateTime.now()),
    );
    if (hora == null) return;

    setModalState(() {
      _dataHoraSelecionada = DateTime(data.year, data.month, data.day, hora.hour, hora.minute);
    });
  }

  void _abrirModalNovoAgendamento() {
    _limparFormulario();
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: _construirModalNovoAgendamento(ctx, setModalState),
          ),
        ),
      ),
    );
  }

  void _enviarFormulario(BuildContext ctx) {
    if (_clienteSelecionado == null || _carroSelecionado == null) {
      CustomToast.show(context, message: 'Selecione o cliente e o veículo', type: ToastType.atencao);
      return;
    }
    if (_dataHoraSelecionada == null) {
      CustomToast.show(context, message: 'Selecione a data e hora', type: ToastType.atencao);
      return;
    }
    if (_descricaoController.text.isEmpty) {
      CustomToast.show(context, message: 'Descreva o serviço', type: ToastType.atencao);
      return;
    }

    final agendamento = AgendamentoModel(
      dataHora: _dataHoraSelecionada!,
      descricaoServico: _descricaoController.text,
      clienteId: _clienteSelecionado!.id,
      carroId: _carroSelecionado!.id,
      mecanicoId: _mecanicoSelecionado?.id,
    );
    _agendamentoBloc.add(CriarAgendamento(agendamento));
    Navigator.pop(ctx);
  }

  Future<void> _confirmarExclusao(int id) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.fundoCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.borda),
        ),
        title: const Text('Excluir Agendamento', style: TextStyle(color: Colors.white, fontSize: 16)),
        content: const Text(
          'Tem certeza que deseja excluir este agendamento? Esta ação não pode ser desfeita.',
          style: TextStyle(color: Colors.white54, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.erro,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmado == true) {
      _agendamentoBloc.add(DeletarAgendamento(id));
    }
  }

// ========= INIT STATE =========

  @override
  void initState() {
    super.initState();
    _agendamentoService = AgendamentoService();
    _agendamentoBloc = AgendamentoBloc(_agendamentoService);
    _descricaoController = TextEditingController();
    _agendamentoBloc.add(CarregarAgendamentos());
    _agendamentoBloc.add(CarregarDadosFormulario());
  }

// ========= COMPONENTES DA TELA =========

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
                'Agenda',
                style: TextStyle(color: AppColors.textoPrincipal, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                'Agendamentos de serviço da oficina',
                style: TextStyle(color: AppColors.textoSecundario, fontSize: 14),
              ),
            ],
          ),
          ElevatedButton.icon(
            onPressed: _abrirModalNovoAgendamento,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaria,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Novo Agendamento', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _construirFiltros(List<AgendamentoModel> todos) {
    final status = <String?>[null, 'AGENDADO', 'CONCLUIDO', 'CANCELADO'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: status.map((s) {
              final selecionado = _filtroStatus == s;
              final label = s == null ? 'Todos' : _labelStatus(s);
              final contagem = s == null ? todos.length : todos.where((a) => a.status == s).length;

              return InkWell(
                onTap: () => setState(() => _filtroStatus = s),
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: selecionado ? AppColors.borda : AppColors.fundoCard,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: selecionado ? AppColors.textoSecundario : AppColors.borda),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          color: selecionado ? AppColors.textoPrincipal : AppColors.textoSecundario,
                          fontSize: 12,
                          fontWeight: selecionado ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: selecionado
                              ? AppColors.textoPrincipal.withValues(alpha: 0.2)
                              : AppColors.textoSecundario.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$contagem',
                          style: TextStyle(
                            color: selecionado ? AppColors.textoPrincipal : AppColors.textoSecundario,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(
                width: 350,
                child: TextField(
                  onChanged: (v) => setState(() => _textoBusca = v),
                  style: const TextStyle(color: AppColors.textoPrincipal, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Buscar por cliente, veículo, mecânico...',
                    hintStyle: const TextStyle(color: AppColors.textoSecundario),
                    prefixIcon: const Icon(Icons.search, color: AppColors.textoSecundario, size: 16),
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
              const SizedBox(width: 16),
              SizedBox(
                width: 320,
                child: CustomDateRangeField(
                  dataInicial: _dataInicialFiltro,
                  dataFinal: _dataFinalFiltro,
                  aoAlterarDataInicial: _aoAlterarDataInicialFiltro,
                  aoAlterarDataFinal: _aoAlterarDataFinalFiltro,
                ),
              ),
              if (_dataInicialFiltro != null || _dataFinalFiltro != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textoSecundario, size: 18),
                  tooltip: 'Limpar filtro de período',
                  onPressed: _limparFiltroPeriodo,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _construirTabela(List<AgendamentoModel> agendamentos) {
    Widget celula(Widget filho, {int flex = 2}) {
      return Expanded(
        flex: flex,
        child: Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: filho,
        ),
      );
    }

    final cabecalhos = [
      celula(const Text('Data/Hora', style: TextStyle(color: AppColors.textoSecundario, fontWeight: FontWeight.bold)), flex: 2),
      celula(const Text('Cliente', style: TextStyle(color: AppColors.textoSecundario, fontWeight: FontWeight.bold))),
      celula(const Text('Veículo', style: TextStyle(color: AppColors.textoSecundario, fontWeight: FontWeight.bold))),
      celula(const Text('Mecânico', style: TextStyle(color: AppColors.textoSecundario, fontWeight: FontWeight.bold))),
      celula(const Text('Serviço', style: TextStyle(color: AppColors.textoSecundario, fontWeight: FontWeight.bold))),
      celula(const Text('Status', style: TextStyle(color: AppColors.textoSecundario, fontWeight: FontWeight.bold))),
      celula(const Text('', style: TextStyle(color: AppColors.textoSecundario)), flex: 1),
    ];

    final linhas = agendamentos.map((agendamento) {
      final cor = _corPorStatus(agendamento.status);
      final label = _labelStatus(agendamento.status);
      final finalizado = agendamento.status != 'AGENDADO';

      return Row(
        children: [
          celula(
            Text(
              _formatarDataHora(agendamento.dataHora),
              style: const TextStyle(color: AppColors.textoPrincipal, fontFamily: 'monospace', fontSize: 12),
            ),
            flex: 2,
          ),
          celula(
            Text(
              agendamento.clienteNome ?? 'N/A',
              style: const TextStyle(color: AppColors.textoPrincipal, fontWeight: FontWeight.w500),
            ),
          ),
          celula(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(agendamento.carroModelo ?? 'N/A', style: const TextStyle(color: AppColors.textoPrincipal, fontSize: 13)),
                Text(agendamento.carroPlaca ?? '---', style: const TextStyle(color: AppColors.textoSecundario, fontSize: 11)),
              ],
            ),
          ),
          celula(
            Text(
              agendamento.mecanicoNome ?? 'Não atribuído',
              style: const TextStyle(color: AppColors.textoPrincipal, fontSize: 13),
            ),
          ),
          celula(
            Text(
              agendamento.descricaoServico,
              style: const TextStyle(color: AppColors.textoPrincipal, fontSize: 13),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          celula(
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: cor.withValues(alpha: 0.15),
                border: Border.all(color: cor.withValues(alpha: 0.3)),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(label, style: TextStyle(color: cor, fontSize: 11, fontWeight: FontWeight.w500)),
            ),
          ),
          celula(
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!finalizado) ...[
                  IconButton(
                    icon: const Icon(Icons.check_circle_outline, color: AppColors.concluido, size: 18),
                    tooltip: 'Concluir',
                    onPressed: () => _agendamentoBloc.add(AtualizarStatusAgendamento(agendamento.id!, 'CONCLUIDO')),
                    splashRadius: 20,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.cancel_outlined, color: AppColors.atencao, size: 18),
                    tooltip: 'Cancelar',
                    onPressed: () => _agendamentoBloc.add(AtualizarStatusAgendamento(agendamento.id!, 'CANCELADO')),
                    splashRadius: 20,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                ],
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppColors.erro, size: 18),
                  tooltip: 'Excluir',
                  onPressed: () => _confirmarExclusao(agendamento.id!),
                  splashRadius: 20,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            flex: 1,
          ),
        ],
      );
    }).toList();

    return TableAll(
      headers: cabecalhos,
      rows: linhas,
      maxRows: 8,
      showActions: false,
      titleEmpty: 'Nenhum Agendamento',
      messageEmpty: 'Tente ajustar os filtros ou criar um novo agendamento.',
    );
  }

  Widget _construirModalNovoAgendamento(BuildContext ctx, StateSetter setModalState) {
    final carrosDoCliente = _clienteSelecionado?.carros ?? [];

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
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Novo Agendamento', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text('Agende um serviço para um cliente.', style: TextStyle(color: Colors.white54, fontSize: 13)),
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
                  _construirLabel('Cliente'),
                  DropdownButtonFormField<ClienteModel>(
                    initialValue: _clienteSelecionado,
                    isExpanded: true,
                    dropdownColor: AppColors.fundoCard,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: _decoracaoDropdown('Selecione o cliente'),
                    items: _clientes
                        .map((c) => DropdownMenuItem(value: c, child: Text(c.nome)))
                        .toList(),
                    onChanged: (v) => setModalState(() {
                      _clienteSelecionado = v;
                      _carroSelecionado = null;
                    }),
                  ),
                  const SizedBox(height: 16),
                  _construirLabel('Veículo'),
                  DropdownButtonFormField<CarroModel>(
                    initialValue: _carroSelecionado,
                    isExpanded: true,
                    dropdownColor: AppColors.fundoCard,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: _decoracaoDropdown(
                      _clienteSelecionado == null ? 'Selecione um cliente primeiro' : 'Selecione o veículo',
                    ),
                    items: carrosDoCliente
                        .map((c) => DropdownMenuItem(value: c, child: Text('${c.modelo} - ${c.placa}')))
                        .toList(),
                    onChanged: carrosDoCliente.isEmpty ? null : (v) => setModalState(() => _carroSelecionado = v),
                  ),
                  const SizedBox(height: 16),
                  _construirLabel('Mecânico (opcional)'),
                  DropdownButtonFormField<MecanicoModel>(
                    initialValue: _mecanicoSelecionado,
                    isExpanded: true,
                    dropdownColor: AppColors.fundoCard,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: _decoracaoDropdown('Selecione o mecânico'),
                    items: _mecanicos
                        .map((m) => DropdownMenuItem(value: m, child: Text(m.nome)))
                        .toList(),
                    onChanged: (v) => setModalState(() => _mecanicoSelecionado = v),
                  ),
                  const SizedBox(height: 16),
                  _construirLabel('Data e Hora'),
                  InkWell(
                    onTap: () => _selecionarDataHora(setModalState),
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: AppColors.fundoPrincipal,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.borda),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined, color: AppColors.textoSecundario, size: 16),
                          const SizedBox(width: 10),
                          Text(
                            _dataHoraSelecionada == null
                                ? 'Selecione a data e hora'
                                : _formatarDataHora(_dataHoraSelecionada!),
                            style: TextStyle(
                              color: _dataHoraSelecionada == null ? Colors.white24 : Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _construirLabel('Descrição do Serviço'),
                  SizedBox(
                    child: TextField(
                      controller: _descricaoController,
                      maxLines: 3,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Descreva o serviço a ser realizado...',
                        hintStyle: const TextStyle(color: Colors.white24),
                        filled: true,
                        fillColor: AppColors.fundoPrincipal,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                  ),
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
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
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
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Agendar', style: TextStyle(fontWeight: FontWeight.w600)),
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
        style: const TextStyle(color: AppColors.textoPrincipal, fontSize: 14, fontWeight: FontWeight.w500),
      ),
    );
  }

  InputDecoration _decoracaoDropdown(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
      filled: true,
      fillColor: AppColors.fundoPrincipal,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: AppColors.borda),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: AppColors.primaria),
      ),
    );
  }

// ========= BLOC BUILDER =========

  Widget _blocBuilder() {
    return BlocConsumer<AgendamentoBloc, AgendamentoState>(
      bloc: _agendamentoBloc,
      listener: (context, estado) {
        if (estado is AgendamentoErro) {
          CustomToast.show(context, message: estado.mensagem, type: ToastType.erro);
        }
        if (estado is AgendamentoSalvo) {
          CustomToast.show(context, message: estado.mensagem, type: ToastType.sucesso);
        }
        if (estado is DadosFormularioCarregados) {
          setState(() {
            _clientes = estado.clientes;
            _mecanicos = estado.mecanicos;
          });
        }
        if (estado is AgendamentosCarregados) {
          setState(() => _agendamentos = estado.agendamentos);
        }
      },
      builder: (context, estado) {
        final agendamentosFiltrados = _agendamentos.where((a) {
          final busca = _textoBusca.toLowerCase();
          final matchBusca = (a.clienteNome ?? '').toLowerCase().contains(busca) ||
              (a.carroModelo ?? '').toLowerCase().contains(busca) ||
              (a.mecanicoNome ?? '').toLowerCase().contains(busca);
          final matchStatus = _filtroStatus == null || a.status == _filtroStatus;
          return matchBusca && matchStatus;
        }).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _construirHeader(),
            _construirFiltros(_agendamentos),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.fundoCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borda),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: (estado is AgendamentoCarregando || estado is AgendamentoInicial) && _agendamentos.isEmpty
                        ? const Center(child: CircularProgressIndicator(color: AppColors.primaria))
                        : _construirTabela(agendamentosFiltrados),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

// ========= BUILD =========

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fundoPrincipal,
      body: _blocBuilder(),
    );
  }

// ========= DISPOSE =========

  @override
  void dispose() {
    _agendamentoBloc.close();
    _descricaoController.dispose();
    super.dispose();
  }
}
