import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oficina_conectada_front/colors/colors.dart';
import 'package:oficina_conectada_front/ordem_de_servico/model/ordem_de_servico_model.dart';
import 'package:oficina_conectada_front/ordem_de_servico/ordem_de_servico_event.dart';
import 'package:oficina_conectada_front/ordem_de_servico/ordem_de_servico_state.dart';
import '../components/headers_cell_text/hearders_cell_text.dart';
import '../components/table_all/table_all.dart';
import '../components/toast/custom_toast.dart';
import 'adicionar_ordem_de_servico/adicionar_ordem_page.dart';
import 'ordem_de_servico_bloc.dart';
import 'ordem_de_servico_repository.dart';

class OrdemServicoPage extends StatefulWidget {
  const OrdemServicoPage({super.key});

  @override
  State<OrdemServicoPage> createState() => _OrdemServicoPageState();
}

class _OrdemServicoPageState extends State<OrdemServicoPage> {
  late OrdemDeServicoBloc _ordemDeServicoBloc;

  void _loadData() {
    _ordemDeServicoBloc.add(CarregarListaDeOrdemDeServico());
  }

  @override
  void initState() {
    super.initState();
    _ordemDeServicoBloc = OrdemDeServicoBloc(OrdemDeServicoRepository());
    _loadData();
  }

  _buildAppBar() {
    return AppBar(
      title: const Text('Ordens de Serviço'),
      backgroundColor: ColorsApp.preto,
      iconTheme: const IconThemeData(color: ColorsApp.branco),
      titleTextStyle: const TextStyle(color: ColorsApp.branco, fontSize: 20),
    );
  }

  _adicionarOrdemServico() {
    return FloatingActionButton(
      onPressed: () => {
        Navigator.push(
          context,
        MaterialPageRoute(
        builder:(_)=> const  CriarOrdemDeServicoPage()
        ),
        )
      },
      backgroundColor: ColorsApp.azul,
      tooltip: 'Adicionar Ordem de Serviço',
      child: const Icon(Icons.add, color: ColorsApp.branco),
    );
  }

  Widget _buildState(OrdemDeServicoState state) {
    switch (state) {
      case OrdemDeServicoLoadingState():
        return const Center(child: CircularProgressIndicator(color: ColorsApp.azulEscuro));
      case OrdemDeServicoListSuccessState():
        return _buildTable(state.ordensDeServico);
      case OrdemDeServicoErrorState():
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 60, color: ColorsApp.vermelho),
              const SizedBox(height: 10),
              const Text(
                'Não foi possível carregar os dados.',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildTable(List<OrdemDeServicoModel> ordens) {
    final headers = [
      const TableHeader(text: 'Cliente', flex: 3),
      const TableHeader(text: 'Carro', flex: 2),
      const TableHeader(text: 'Placa', flex: 2),
      const TableHeader(text: 'Status', flex: 2,),
      const TableHeader(text: 'Ações', flex: 1, center: true),
    ];

    final rows = ordens.map((ordem) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            TableCellText(text: ordem.cliente.toString(), flex: 3),
            TableCellText(text: ordem.carro.toString(), flex: 2),
            TableCellText(text: ordem.placa.toString(), flex: 2),
            Expanded(
              flex: 2,
              child: Text(
                _formatStatus(ordem.status.name),
                style: TextStyle(
                  color: _getStatusColor(ordem.status.name),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: ColorsApp.cianoEscuro, size: 20),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                    onPressed: () {
                      _ordemDeServicoBloc.add(DeletarOrdemDeServico(ordem.id!));
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }).toList();

    return TableAll(headers: headers, rows: rows, maxRows: 10);
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'EM_ANDAMENTO':
        return Colors.blueAccent;
      case 'AGUARDANDO_PECA':
        return Colors.orangeAccent;
      case 'FINALIZADO':
        return Colors.greenAccent;
      case 'CANCELADO':
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

  String _formatStatus(String status) {
    return status.replaceAll('_', ' ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsApp.preto,
      appBar: _buildAppBar(),
      floatingActionButton: _adicionarOrdemServico(),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return BlocConsumer<OrdemDeServicoBloc, OrdemDeServicoState>(
      bloc: _ordemDeServicoBloc,
      listener: _blocListener,
      builder: (context, state) {
        return Padding(padding: const EdgeInsets.all(16.0), child: _buildState(state));
      },
    );
  }

  void _blocListener(BuildContext context, OrdemDeServicoState state) {
    if (state is OrdemDeServicoErrorState) {
      CustomToast.show(context, message: state.message, type: ToastType.error);
    }

    if (state is OrdemDeServicoDelatadaComSucesso) {
      CustomToast.show(
        context,
        message: 'Ordem de serviço deletada com sucesso',
        type: ToastType.success,
      );
      _loadData();
    }
  }

  @override
  void dispose() {
    _ordemDeServicoBloc.close();
    super.dispose();
  }
}
