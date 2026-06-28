import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oficina_conectada_front/core/constants/app_colors.dart';
import 'package:oficina_conectada_front/models/carro_model.dart';
import 'package:oficina_conectada_front/modules/veiculos/veiculos_bloc.dart';
import 'package:oficina_conectada_front/modules/veiculos/veiculos_event.dart';
import 'package:oficina_conectada_front/modules/veiculos/veiculos_service.dart';
import 'package:oficina_conectada_front/modules/veiculos/veiculos_state.dart';
import 'package:oficina_conectada_front/shared/widgets/custom_toast/custom_toast.dart';

class VeiculosPage extends StatefulWidget {
  const VeiculosPage({super.key});

  @override
  State<VeiculosPage> createState() => _VeiculosPageState();
}

class _VeiculosPageState extends State<VeiculosPage> {


  late VeiculosBloc _veiculosBloc;
  late VeiculosService _veiculosService;
  late TextEditingController _marcaController;
  late TextEditingController _modeloController;
  late TextEditingController _placaController;
  late TextEditingController _anoController;
  late TextEditingController _corController;


  String _textoBusca = '';
  String _filtroStatus = 'todos';
  int? _clienteSelecionadoId;



  Map<String, dynamic> _statusUi(String? statusBackend) {
    if (statusBackend == null ||
        statusBackend == 'CONCLUIDA' ||
        statusBackend == 'ENTREGUE' ||
        statusBackend == 'FINALIZADO') {
      return {'chave': 'disponivel', 'label': 'Disponível', 'cor': AppColors.concluido};
    }
    if (statusBackend.contains('AGUARDANDO')) {
      return {'chave': 'aguardando', 'label': 'Aguardando', 'cor': AppColors.atencao};
    }
    return {'chave': 'em_servico', 'label': 'Em Serviço', 'cor': AppColors.emAndamento};
  }

  void _limparFormulario() {
    _marcaController.clear();
    _modeloController.clear();
    _placaController.clear();
    _anoController.clear();
    _corController.clear();
    _clienteSelecionadoId = null;
  }

  void _abrirModalNovoVeiculo() {
    _limparFormulario();
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: _construirModalNovoVeiculo(ctx),
        ),
      ),
    );
  }

  void _enviarFormulario(BuildContext ctx) {
    if (_placaController.text.isEmpty) {
      CustomToast.show(context, message: 'A placa é obrigatória', type: ToastType.atencao);
      return;
    }
    if (_clienteSelecionadoId == null) {
      CustomToast.show(context, message: 'Selecione o proprietário', type: ToastType.atencao);
      return;
    }

    final novoCarro = CarroModel(
      placa: _placaController.text.toUpperCase(),
      modelo: _modeloController.text,
      marca: _marcaController.text,
      ano: int.tryParse(_anoController.text),
      cor: _corController.text,
      clienteId: _clienteSelecionadoId,
    );

    _veiculosBloc.add(CriarVeiculo(novoCarro));
    Navigator.pop(ctx);
  }

  Future<void> _confirmarDelecao(int id, String nome) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.fundoCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.borda),
        ),
        title: const Text('Remover Veículo', style: TextStyle(color: Colors.white, fontSize: 16)),
        content: Text(
          'Tem certeza que deseja remover "$nome"? Esta ação não pode ser desfeita.',
          style: const TextStyle(color: Colors.white54, fontSize: 14),
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
            child: const Text('Remover'),
          ),
        ],
      ),
    );
    if (confirmado == true) {
      _veiculosBloc.add(DeletarVeiculo(id));
    }
  }


  @override
  void initState() {
    super.initState();
    _veiculosService = VeiculosService();
    _veiculosBloc = VeiculosBloc(_veiculosService);
    _marcaController = TextEditingController();
    _modeloController = TextEditingController();
    _placaController = TextEditingController();
    _anoController = TextEditingController();
    _corController = TextEditingController();
    _veiculosBloc.add(CarregarVeiculos());
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
                'Veículos',
                style: TextStyle(color: AppColors.textoPrincipal, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                'Gerenciamento de veículos cadastrados na oficina',
                style: TextStyle(color: AppColors.textoSecundario, fontSize: 14),
              ),
            ],
          ),
          ElevatedButton.icon(
            onPressed: _abrirModalNovoVeiculo,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaria,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Novo Veículo', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _construirKpis(List<CarroStatusModel> frota) {
    int emServico = 0, aguardando = 0, disponivel = 0;
    for (final item in frota) {
      final chave = _statusUi(item.status)['chave'] as String;
      if (chave == 'em_servico') emServico++;
      else if (chave == 'aguardando') aguardando++;
      else disponivel++;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(child: _construirCardKpi('Em Serviço', emServico, AppColors.emAndamento)),
          const SizedBox(width: 16),
          Expanded(child: _construirCardKpi('Aguardando', aguardando, AppColors.atencao)),
          const SizedBox(width: 16),
          Expanded(child: _construirCardKpi('Disponível', disponivel, AppColors.concluido)),
        ],
      ),
    );
  }

  Widget _construirCardKpi(String titulo, int contagem, Color cor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.fundoCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borda),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: cor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.directions_car, color: cor, size: 20),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                contagem.toString(),
                style: const TextStyle(color: AppColors.textoPrincipal, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(titulo, style: const TextStyle(color: AppColors.textoSecundario, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _construirFiltrosEBusca(List<CarroStatusModel> frota) {
    int emServico = 0, aguardando = 0, disponivel = 0;
    for (final item in frota) {
      final chave = _statusUi(item.status)['chave'] as String;
      if (chave == 'em_servico') emServico++;
      else if (chave == 'aguardando') aguardando++;
      else disponivel++;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              _construirBotaoFiltro('Todos', 'todos', frota.length),
              const SizedBox(width: 8),
              _construirBotaoFiltro('Em Serviço', 'em_servico', emServico),
              const SizedBox(width: 8),
              _construirBotaoFiltro('Aguardando', 'aguardando', aguardando),
              const SizedBox(width: 8),
              _construirBotaoFiltro('Disponível', 'disponivel', disponivel),
            ],
          ),
          SizedBox(
            width: 300,
            child: TextField(
              onChanged: (v) => setState(() => _textoBusca = v),
              style: const TextStyle(color: AppColors.textoPrincipal, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Buscar por modelo, placa, proprietário...',
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
        ],
      ),
    );
  }

  Widget _construirBotaoFiltro(String label, String chave, int contagem) {
    final selecionado = _filtroStatus == chave;
    return InkWell(
      onTap: () => setState(() => _filtroStatus = chave),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selecionado ? AppColors.primaria : AppColors.fundoCard,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: selecionado ? AppColors.primaria : AppColors.borda),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                color: selecionado ? Colors.white : AppColors.textoSecundario,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: selecionado
                    ? Colors.white.withValues(alpha: 0.2)
                    : AppColors.fundoPrincipal,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                contagem.toString(),
                style: TextStyle(
                  color: selecionado ? Colors.white : AppColors.textoSecundario,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirTabela(List<CarroStatusModel> frota) {
    if (frota.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.fundoCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borda),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.directions_car_outlined, color: Colors.white24, size: 40),
              SizedBox(height: 12),
              Text('Nenhum veículo encontrado', style: TextStyle(color: Colors.white54)),
            ],
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.fundoCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borda),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.borda)),
            ),
            child: const Row(
              children: [
                Expanded(flex: 3, child: Text('Veículo', style: TextStyle(color: AppColors.textoSecundario, fontSize: 13, fontWeight: FontWeight.w600))),
                Expanded(flex: 2, child: Text('Placa', style: TextStyle(color: AppColors.textoSecundario, fontSize: 13, fontWeight: FontWeight.w600))),
                Expanded(flex: 1, child: Text('Ano', style: TextStyle(color: AppColors.textoSecundario, fontSize: 13, fontWeight: FontWeight.w600))),
                Expanded(flex: 1, child: Text('Cor', style: TextStyle(color: AppColors.textoSecundario, fontSize: 13, fontWeight: FontWeight.w600))),
                Expanded(flex: 3, child: Text('Proprietário', style: TextStyle(color: AppColors.textoSecundario, fontSize: 13, fontWeight: FontWeight.w600))),
                Expanded(flex: 2, child: Text('Status', style: TextStyle(color: AppColors.textoSecundario, fontSize: 13, fontWeight: FontWeight.w600))),
                SizedBox(width: 40),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: frota.length,
              separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.borda),
              itemBuilder: (context, index) {
                final item = frota[index];
                final c = item.carro;
                final ui = _statusUi(item.status);
                final cor = ui['cor'] as Color;

                return InkWell(
                  onTap: () {},
                  hoverColor: Colors.white.withValues(alpha: 0.02),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppColors.fundoPrincipal,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(Icons.directions_car_outlined, color: AppColors.primaria, size: 16),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  '${c.marca ?? ''} ${c.modelo}'.trim(),
                                  style: const TextStyle(color: AppColors.textoPrincipal, fontSize: 14, fontWeight: FontWeight.w500),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            c.placa,
                            style: const TextStyle(color: AppColors.primaria, fontSize: 13, fontFamily: 'monospace', fontWeight: FontWeight.w600),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            c.ano?.toString() ?? '-',
                            style: const TextStyle(color: AppColors.textoSecundario, fontSize: 13),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            c.cor ?? '-',
                            style: const TextStyle(color: AppColors.textoSecundario, fontSize: 13),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Row(
                            children: [
                              const Icon(Icons.person_outline, color: AppColors.textoSecundario, size: 14),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  c.nomeCliente ?? 'Sem proprietário',
                                  style: const TextStyle(color: AppColors.textoPrincipal, fontSize: 13),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Container(
                            width: 100,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: cor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: cor.withValues(alpha: 0.3)),
                            ),
                            child: Text(
                              ui['label'] as String,
                              style: TextStyle(color: cor, fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 40,
                          child: PopupMenuButton<String>(
                            icon: const Icon(Icons.more_horiz, color: AppColors.textoSecundario, size: 20),
                            color: AppColors.fundoCard,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: const BorderSide(color: AppColors.borda),
                            ),
                            onSelected: (val) {
                              if (val == 'excluir') {
                                _confirmarDelecao(c.id!, '${c.marca ?? ''} ${c.modelo} (${c.placa})'.trim());
                              } else {
                                CustomToast.show(context, message: 'Em breve!', type: ToastType.atencao);
                              }
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(value: 'historico', child: Text('Ver Histórico', style: TextStyle(color: Colors.white, fontSize: 13))),
                              PopupMenuItem(value: 'editar', child: Text('Editar', style: TextStyle(color: Colors.white, fontSize: 13))),
                              PopupMenuItem(value: 'os', child: Text('Nova OS', style: TextStyle(color: Colors.white, fontSize: 13))),
                              PopupMenuItem(value: 'excluir', child: Text('Remover', style: TextStyle(color: Colors.redAccent, fontSize: 13))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirModalNovoVeiculo(BuildContext ctx) {
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
                Row(
                  children: [
                    const Icon(Icons.directions_car, color: AppColors.primaria, size: 22),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Cadastrar Veículo', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text('Preencha as informações do veículo.', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13)),
                      ],
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
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _construirCampoModal(_marcaController, 'Marca', 'Ex: Honda',
                          capitalizacao: TextCapitalization.words),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _construirCampoModal(_modeloController, 'Modelo', 'Ex: Civic',
                          capitalizacao: TextCapitalization.words),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: _construirCampoModal(_placaController, 'Placa', 'ABC-1D23',
                          capitalizacao: TextCapitalization.characters,
                          formatadores: [_UpperCaseFormatter()]),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _construirCampoModal(_anoController, 'Ano', '2024',
                          teclado: TextInputType.number),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: _construirCampoModal(_corController, 'Cor', 'Prata'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Divider(height: 1, color: Colors.white10),
                const SizedBox(height: 16),
                const Text(
                  'Proprietário',
                  style: TextStyle(color: AppColors.textoPrincipal, fontSize: 13, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.fundoPrincipal,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.borda),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: AppColors.atencao, size: 16),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Para vincular a um cliente, cadastre o veículo diretamente na tela de Clientes.',
                          style: TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
                  child: const Text('Cadastrar', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirCampoModal(
    TextEditingController controller,
    String label,
    String hint, {
    TextInputType teclado = TextInputType.text,
    List<TextInputFormatter>? formatadores,
    TextCapitalization capitalizacao = TextCapitalization.none,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(label, style: const TextStyle(color: AppColors.textoPrincipal, fontSize: 13, fontWeight: FontWeight.w500)),
        ),
        SizedBox(
          height: 40,
          child: TextField(
            controller: controller,
            keyboardType: teclado,
            inputFormatters: formatadores,
            textCapitalization: capitalizacao,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.white24),
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
            ),
          ),
        ),
      ],
    );
  }


  Widget _blocBuilder() {
    return BlocConsumer<VeiculosBloc, VeiculosState>(
      bloc: _veiculosBloc,
      listener: (context, estado) {
        if (estado is VeiculosErro) {
          CustomToast.show(context, message: estado.mensagem, type: ToastType.erro);
        }
        if (estado is VeiculoCriado) {
          CustomToast.show(context, message: 'Veículo cadastrado com sucesso!', type: ToastType.sucesso);
        }
        if (estado is VeiculoDeletado) {
          CustomToast.show(context, message: 'Veículo removido com sucesso!', type: ToastType.sucesso);
        }
      },
      builder: (context, estado) {
        List<CarroStatusModel> frota = [];
        if (estado is VeiculosCarregados) frota = estado.veiculos;

        final frotaFiltrada = frota.where((item) {
          final busca = _textoBusca.toLowerCase();
          final c = item.carro;
          final matchBusca = c.placa.toLowerCase().contains(busca) ||
              c.modelo.toLowerCase().contains(busca) ||
              (c.marca ?? '').toLowerCase().contains(busca) ||
              (c.nomeCliente ?? '').toLowerCase().contains(busca);
          final chave = _statusUi(item.status)['chave'] as String;
          final matchStatus = _filtroStatus == 'todos' || chave == _filtroStatus;
          return matchBusca && matchStatus;
        }).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _construirHeader(),
            _construirKpis(frota),
            const SizedBox(height: 24),
            _construirFiltrosEBusca(frota),
            const SizedBox(height: 16),
            Expanded(
              child: estado is VeiculosCarregando && frota.isEmpty
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primaria))
                  : _construirTabela(frotaFiltrada),
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
    _veiculosBloc.close();
    _marcaController.dispose();
    _modeloController.dispose();
    _placaController.dispose();
    _anoController.dispose();
    _corController.dispose();
    super.dispose();
  }
}

class _UpperCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(text: newValue.text.toUpperCase(), selection: newValue.selection);
  }
}
