import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oficina_conectada_front/core/constants/app_colors.dart';
import 'package:oficina_conectada_front/modules/ordens/adicionar_ordem/adicionar_ordem_page.dart';
import 'package:oficina_conectada_front/modules/ordens/ordens_bloc.dart';
import 'package:oficina_conectada_front/modules/ordens/ordens_event.dart';
import 'package:oficina_conectada_front/modules/ordens/ordens_model.dart';
import 'package:oficina_conectada_front/modules/ordens/ordens_service.dart';
import 'package:oficina_conectada_front/modules/ordens/ordens_state.dart';
import 'package:oficina_conectada_front/shared/widgets/custom_toast/custom_toast.dart';
import 'package:oficina_conectada_front/widgets/table_all/table_all.dart';

class OrdensPage extends StatefulWidget {
  const OrdensPage({super.key});

  @override
  State<OrdensPage> createState() => _OrdensPageState();
}

class _OrdensPageState extends State<OrdensPage> {


  late OrdensBloc _ordensBloc;
  late OrdensService _ordensService;


  String _textoBusca = '';
  StatusOrdemDeServico? _filtroStatus;


  void _carregarDados() => _ordensBloc.add(CarregarOrdens());

  Future<void> _confirmarDelecao(int id) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.fundoCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.borda),
        ),
        title: const Text('Excluir Ordem de Serviço', style: TextStyle(color: Colors.white, fontSize: 16)),
        content: const Text(
          'Tem certeza que deseja excluir esta OS? Esta ação não pode ser desfeita.',
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
      _ordensBloc.add(DeletarOrdem(id));
    }
  }

  void _aoClicarNovaOs() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AdicionarOrdemPage()),
    ).then((_) => _carregarDados());
  }

  Color _corPorStatus(StatusOrdemDeServico status) {
    switch (status) {
      case StatusOrdemDeServico.NAO_INICIADO:
        return AppColors.textoSecundario;
      case StatusOrdemDeServico.EM_ANDAMENTO:
        return AppColors.emAndamento;
      case StatusOrdemDeServico.AGUARDANDO_PECA:
        return AppColors.atencao;
      case StatusOrdemDeServico.AGUARDANDO_RETIRADA:
        return AppColors.atencao;
      case StatusOrdemDeServico.FINALIZADO:
        return AppColors.concluido;
      case StatusOrdemDeServico.CANCELADO:
        return AppColors.erro;
    }
  }

  String _labelStatus(StatusOrdemDeServico status) {
    switch (status) {
      case StatusOrdemDeServico.NAO_INICIADO:
        return 'Não Iniciada';
      case StatusOrdemDeServico.EM_ANDAMENTO:
        return 'Em Andamento';
      case StatusOrdemDeServico.AGUARDANDO_PECA:
        return 'Aguard. Peça';
      case StatusOrdemDeServico.AGUARDANDO_RETIRADA:
        return 'Aguard. Retirada';
      case StatusOrdemDeServico.FINALIZADO:
        return 'Concluída';
      case StatusOrdemDeServico.CANCELADO:
        return 'Cancelada';
    }
  }

  IconData _iconeStatus(StatusOrdemDeServico status) {
    switch (status) {
      case StatusOrdemDeServico.NAO_INICIADO:
        return Icons.schedule;
      case StatusOrdemDeServico.EM_ANDAMENTO:
        return Icons.build_circle_outlined;
      case StatusOrdemDeServico.AGUARDANDO_PECA:
        return Icons.inventory_2_outlined;
      case StatusOrdemDeServico.AGUARDANDO_RETIRADA:
        return Icons.hail_outlined;
      case StatusOrdemDeServico.FINALIZADO:
        return Icons.check_circle_outline;
      case StatusOrdemDeServico.CANCELADO:
        return Icons.cancel_outlined;
    }
  }


  @override
  void initState() {
    super.initState();
    _ordensService = OrdensService();
    _ordensBloc = OrdensBloc(_ordensService);
    _carregarDados();
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
                'Ordens de Serviço',
                style: TextStyle(
                  color: AppColors.textoPrincipal,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Gerencie todas as ordens de serviço da oficina',
                style: TextStyle(color: AppColors.textoSecundario, fontSize: 14),
              ),
            ],
          ),
          ElevatedButton.icon(
            onPressed: _aoClicarNovaOs,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaria,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Nova OS', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _construirFiltros(List<OrdemDeServicoModel> todasOrdens) {
    final contagemStatus = <StatusOrdemDeServico?, int>{
      null: todasOrdens.length,
      for (var s in StatusOrdemDeServico.values)
        s: todasOrdens.where((o) => o.status == s).length,
    };

    final abas = [null, ...StatusOrdemDeServico.values];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: abas.map((status) {
              final selecionado = _filtroStatus == status;
              final label = status == null ? 'Todas' : _labelStatus(status);
              final contagem = contagemStatus[status] ?? 0;

              return InkWell(
                onTap: () => setState(() => _filtroStatus = status),
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: selecionado ? AppColors.borda : AppColors.fundoCard,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: selecionado ? AppColors.textoSecundario : AppColors.borda,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          color: selecionado
                              ? AppColors.textoPrincipal
                              : AppColors.textoSecundario,
                          fontSize: 12,
                          fontWeight:
                              selecionado ? FontWeight.bold : FontWeight.normal,
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
                            color: selecionado
                                ? AppColors.textoPrincipal
                                : AppColors.textoSecundario,
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
          SizedBox(
            width: 350,
            child: TextField(
              onChanged: (v) => setState(() => _textoBusca = v),
              style: const TextStyle(color: AppColors.textoPrincipal, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Buscar por cliente, veículo, placa...',
                hintStyle: const TextStyle(color: AppColors.textoSecundario),
                prefixIcon: const Icon(Icons.search, color: AppColors.textoSecundario, size: 18),
                filled: true,
                fillColor: AppColors.fundoPrincipal,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.borda),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.textoSecundario),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirTabela(List<OrdemDeServicoModel> ordens) {
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
      celula(const Text('OS', style: TextStyle(color: AppColors.textoSecundario, fontWeight: FontWeight.bold)), flex: 1),
      celula(const Text('Cliente', style: TextStyle(color: AppColors.textoSecundario, fontWeight: FontWeight.bold))),
      celula(const Text('Veículo', style: TextStyle(color: AppColors.textoSecundario, fontWeight: FontWeight.bold))),
      celula(const Text('Serviço', style: TextStyle(color: AppColors.textoSecundario, fontWeight: FontWeight.bold))),
      celula(const Text('Status', style: TextStyle(color: AppColors.textoSecundario, fontWeight: FontWeight.bold))),
      celula(const Text('Valor', style: TextStyle(color: AppColors.textoSecundario, fontWeight: FontWeight.bold)), flex: 1),
      celula(const Text('', style: TextStyle(color: AppColors.textoSecundario)), flex: 1),
    ];

    final linhas = ordens.map((ordem) {
      final cor = _corPorStatus(ordem.status);
      final label = _labelStatus(ordem.status);
      final icone = _iconeStatus(ordem.status);

      return Row(
        children: [
          celula(
            Text(
              'OS-${ordem.id ?? "000"}',
              style: const TextStyle(color: AppColors.textoSecundario, fontFamily: 'monospace', fontSize: 12),
            ),
            flex: 1,
          ),
          celula(
            Text(
              ordem.cliente ?? 'N/A',
              style: const TextStyle(color: AppColors.textoPrincipal, fontWeight: FontWeight.w500),
            ),
          ),
          celula(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(ordem.carro ?? 'N/A', style: const TextStyle(color: AppColors.textoPrincipal, fontSize: 13)),
                Text(ordem.placa ?? '---', style: const TextStyle(color: AppColors.textoSecundario, fontSize: 11)),
              ],
            ),
          ),
          celula(
            Text(
              ordem.descricaoServico ?? 'N/A',
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
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icone, color: cor, size: 12),
                  const SizedBox(width: 4),
                  Text(label, style: TextStyle(color: cor, fontSize: 11, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ),
          celula(
            Text(
              'R\$ ${ordem.valorTotal?.toStringAsFixed(2) ?? "0.00"}',
              style: const TextStyle(color: AppColors.textoPrincipal, fontFamily: 'monospace'),
            ),
            flex: 1,
          ),
          celula(
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: AppColors.textoSecundario, size: 18),
                  onPressed: () => CustomToast.show(context, message: 'Edição de OS em breve!', type: ToastType.atencao),
                  splashRadius: 20,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppColors.erro, size: 18),
                  onPressed: () => _confirmarDelecao(ordem.id!),
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
      maxRows: 7,
      showActions: false,
      titleEmpty: 'Nenhuma Ordem de Serviço',
      messageEmpty: 'Tente ajustar os filtros ou criar uma nova OS.',
    );
  }

  Widget _construirErro() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: AppColors.erro),
          SizedBox(height: 16),
          Text(
            'Não foi possível carregar as ordens de serviço.',
            style: TextStyle(color: AppColors.textoSecundario),
          ),
        ],
      ),
    );
  }


  Widget _blocBuilder() {
    return BlocConsumer<OrdensBloc, OrdensState>(
      bloc: _ordensBloc,
      listener: (context, estado) {
        if (estado is OrdensErro) {
          CustomToast.show(context, message: estado.mensagem, type: ToastType.erro);
        }
        if (estado is OrdemDeletada) {
          CustomToast.show(context, message: 'Ordem de serviço deletada com sucesso', type: ToastType.sucesso);
        }
      },
      builder: (context, estado) {
        List<OrdemDeServicoModel> ordens = [];
        if (estado is OrdensCarregadas) {
          ordens = estado.ordens;
        }

        final ordensFiltradas = ordens.where((ordem) {
          final matchBusca =
              (ordem.cliente?.toLowerCase() ?? '').contains(_textoBusca.toLowerCase()) ||
              (ordem.carro?.toLowerCase() ?? '').contains(_textoBusca.toLowerCase()) ||
              (ordem.placa?.toLowerCase() ?? '').contains(_textoBusca.toLowerCase());
          final matchStatus = _filtroStatus == null || ordem.status == _filtroStatus;
          return matchBusca && matchStatus;
        }).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _construirHeader(),
            _construirFiltros(ordens),
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
                    child: estado is OrdensCarregando || estado is OrdensInicial
                        ? const Center(child: CircularProgressIndicator(color: AppColors.primaria))
                        : estado is OrdensErro
                            ? _construirErro()
                            : _construirTabela(ordensFiltradas),
                  ),
                ),
              ),
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
    _ordensBloc.close();
    super.dispose();
  }
}
