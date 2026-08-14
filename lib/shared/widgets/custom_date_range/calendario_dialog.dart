import 'package:flutter/material.dart';
import 'package:oficina_conectada_front/core/constants/app_colors.dart';

class CalendarioDialog extends StatefulWidget {
  final DateTime dataInicial;
  final DateTime limiteMinimo;
  final DateTime limiteMaximo;

  const CalendarioDialog({
    super.key,
    required this.dataInicial,
    required this.limiteMinimo,
    required this.limiteMaximo,
  });

  @override
  State<CalendarioDialog> createState() => _CalendarioDialogState();
}

class _CalendarioDialogState extends State<CalendarioDialog> {
  late DateTime _mesExibido;
  late DateTime _dataSelecionada;

  static const List<String> _nomesMeses = [
    'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
    'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro',
  ];
  static const List<String> _nomesDiasSemana = ['D', 'S', 'T', 'Q', 'Q', 'S', 'S'];

  @override
  void initState() {
    super.initState();
    _dataSelecionada = widget.dataInicial;
    _mesExibido = DateTime(widget.dataInicial.year, widget.dataInicial.month);
  }

  bool _dentroDoLimite(DateTime dia) {
    return !dia.isBefore(widget.limiteMinimo) && !dia.isAfter(widget.limiteMaximo);
  }

  void _irParaMesAnterior() {
    setState(() => _mesExibido = DateTime(_mesExibido.year, _mesExibido.month - 1));
  }

  void _irParaProximoMes() {
    setState(() => _mesExibido = DateTime(_mesExibido.year, _mesExibido.month + 1));
  }

  List<DateTime?> _construirDiasDoMes() {
    final primeiroDia = DateTime(_mesExibido.year, _mesExibido.month, 1);
    final ultimoDia = DateTime(_mesExibido.year, _mesExibido.month + 1, 0);
    final offsetInicial = primeiroDia.weekday % 7;

    final dias = <DateTime?>[];
    dias.addAll(List.filled(offsetInicial, null));
    for (int i = 1; i <= ultimoDia.day; i++) {
      dias.add(DateTime(_mesExibido.year, _mesExibido.month, i));
    }
    return dias;
  }

  @override
  Widget build(BuildContext context) {
    final dias = _construirDiasDoMes();
    final podeVoltar = DateTime(_mesExibido.year, _mesExibido.month, 1)
        .isAfter(DateTime(widget.limiteMinimo.year, widget.limiteMinimo.month, 1));
    final podeAvancar = DateTime(_mesExibido.year, _mesExibido.month, 1)
        .isBefore(DateTime(widget.limiteMaximo.year, widget.limiteMaximo.month, 1));

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 320,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.fundoCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borda),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left, color: Colors.white),
                  onPressed: podeVoltar ? _irParaMesAnterior : null,
                  splashRadius: 18,
                ),
                Text(
                  '${_nomesMeses[_mesExibido.month - 1]} ${_mesExibido.year}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right, color: Colors.white),
                  onPressed: podeAvancar ? _irParaProximoMes : null,
                  splashRadius: 18,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: _nomesDiasSemana
                  .map((d) => Expanded(
                        child: Center(
                          child: Text(
                            d,
                            style: const TextStyle(color: AppColors.textoSecundario, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 4),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: dias.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7),
              itemBuilder: (context, index) {
                final dia = dias[index];
                if (dia == null) return const SizedBox.shrink();

                final habilitado = _dentroDoLimite(dia);
                final selecionado = dia.year == _dataSelecionada.year &&
                    dia.month == _dataSelecionada.month &&
                    dia.day == _dataSelecionada.day;

                return InkWell(
                  onTap: habilitado ? () => setState(() => _dataSelecionada = dia) : null,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: selecionado ? AppColors.primaria : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${dia.day}',
                      style: TextStyle(
                        color: !habilitado
                            ? Colors.white24
                            : selecionado
                                ? Colors.white
                                : Colors.white70,
                        fontSize: 13,
                        fontWeight: selecionado ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, _dataSelecionada),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaria,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Selecionar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
