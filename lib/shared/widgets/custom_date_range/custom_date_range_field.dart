import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:oficina_conectada_front/core/constants/app_colors.dart';
import 'package:oficina_conectada_front/shared/widgets/custom_date_range/calendario_dialog.dart';
import 'package:oficina_conectada_front/shared/widgets/custom_toast/custom_toast.dart';

class CustomDateRangeField extends StatefulWidget {
  final DateTime? dataInicial;
  final DateTime? dataFinal;
  final ValueChanged<DateTime?> aoAlterarDataInicial;
  final ValueChanged<DateTime?> aoAlterarDataFinal;

  const CustomDateRangeField({
    super.key,
    required this.dataInicial,
    required this.dataFinal,
    required this.aoAlterarDataInicial,
    required this.aoAlterarDataFinal,
  });

  @override
  State<CustomDateRangeField> createState() => _CustomDateRangeFieldState();
}

class _CustomDateRangeFieldState extends State<CustomDateRangeField> {
  static final DateTime _limiteMinimo = DateTime(2001, 1, 1);

  late TextEditingController _controllerInicial;
  late TextEditingController _controllerFinal;
  final _mascaraInicial = MaskTextInputFormatter(mask: '##/##/####', filter: {'#': RegExp(r'[0-9]')});
  final _mascaraFinal = MaskTextInputFormatter(mask: '##/##/####', filter: {'#': RegExp(r'[0-9]')});

  DateTime get _hoje {
    final agora = DateTime.now();
    return DateTime(agora.year, agora.month, agora.day);
  }

  @override
  void initState() {
    super.initState();
    _controllerInicial = TextEditingController(text: _formatar(widget.dataInicial));
    _controllerFinal = TextEditingController(text: _formatar(widget.dataFinal));
  }

  @override
  void didUpdateWidget(covariant CustomDateRangeField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.dataInicial != widget.dataInicial) {
      _controllerInicial.text = _formatar(widget.dataInicial);
    }
    if (oldWidget.dataFinal != widget.dataFinal) {
      _controllerFinal.text = _formatar(widget.dataFinal);
    }
  }

  String _formatar(DateTime? data) {
    if (data == null) return '';
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    return '$dia/$mes/${data.year}';
  }

  DateTime? _tentarConverter(String texto) {
    if (texto.length != 10) return null;
    final dia = int.tryParse(texto.substring(0, 2));
    final mes = int.tryParse(texto.substring(3, 5));
    final ano = int.tryParse(texto.substring(6, 10));
    if (dia == null || mes == null || ano == null) return null;
    if (mes < 1 || mes > 12) return null;

    final data = DateTime(ano, mes, dia);
    if (data.day != dia || data.month != mes || data.year != ano) return null;
    return data;
  }

  void _mostrarErro(String mensagem) {
    CustomToast.show(context, message: mensagem, type: ToastType.erro);
  }

  void _aoDigitarInicial(String texto) {
    if (texto.length < 10) return;

    final data = _tentarConverter(texto);
    if (data == null) {
      _mostrarErro('Data inicial inválida');
      _controllerInicial.text = _formatar(widget.dataInicial);
      return;
    }
    if (data.isBefore(_limiteMinimo)) {
      _mostrarErro('A data inicial não pode ser anterior a 01/01/2001');
      _controllerInicial.text = _formatar(widget.dataInicial);
      return;
    }
    if (data.isAfter(_hoje)) {
      _mostrarErro('A data inicial não pode ser no futuro');
      _controllerInicial.text = _formatar(widget.dataInicial);
      return;
    }
    if (widget.dataFinal != null && data.isAfter(widget.dataFinal!)) {
      _mostrarErro('A data inicial não pode ser maior que a data final');
      _controllerInicial.text = _formatar(widget.dataInicial);
      return;
    }
    widget.aoAlterarDataInicial(data);
  }

  void _aoDigitarFinal(String texto) {
    if (texto.length < 10) return;

    final data = _tentarConverter(texto);
    if (data == null) {
      _mostrarErro('Data final inválida');
      _controllerFinal.text = _formatar(widget.dataFinal);
      return;
    }
    if (data.isBefore(_limiteMinimo)) {
      _mostrarErro('A data final não pode ser anterior a 01/01/2001');
      _controllerFinal.text = _formatar(widget.dataFinal);
      return;
    }
    if (data.isAfter(_hoje)) {
      _mostrarErro('A data final não pode ser no futuro');
      _controllerFinal.text = _formatar(widget.dataFinal);
      return;
    }
    if (widget.dataInicial != null && data.isBefore(widget.dataInicial!)) {
      _mostrarErro('A data final não pode ser menor que a data inicial');
      _controllerFinal.text = _formatar(widget.dataFinal);
      return;
    }
    widget.aoAlterarDataFinal(data);
  }

  Future<void> _abrirCalendario({required bool inicial}) async {
    final limiteMaximo = inicial ? (widget.dataFinal ?? _hoje) : _hoje;
    final limiteMinimoCampo = inicial ? _limiteMinimo : (widget.dataInicial ?? _limiteMinimo);
    final valorAtual = inicial ? widget.dataInicial : widget.dataFinal;

    final escolhida = await showDialog<DateTime>(
      context: context,
      builder: (ctx) => CalendarioDialog(
        dataInicial: valorAtual ?? limiteMaximo,
        limiteMinimo: limiteMinimoCampo,
        limiteMaximo: limiteMaximo,
      ),
    );

    if (escolhida == null) return;
    if (inicial) {
      _controllerInicial.text = _formatar(escolhida);
      widget.aoAlterarDataInicial(escolhida);
    } else {
      _controllerFinal.text = _formatar(escolhida);
      widget.aoAlterarDataFinal(escolhida);
    }
  }

  Widget _construirCampo({
    required String label,
    required TextEditingController controller,
    required MaskTextInputFormatter mascara,
    required ValueChanged<String> aoMudar,
    required VoidCallback aoTocarCalendario,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(
            label,
            style: const TextStyle(color: AppColors.textoPrincipal, fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
        SizedBox(
          height: 40,
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [mascara],
            onChanged: aoMudar,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'dd/mm/aaaa',
              hintStyle: const TextStyle(color: Colors.white24),
              filled: true,
              fillColor: AppColors.fundoPrincipal,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
              suffixIcon: InkWell(
                onTap: aoTocarCalendario,
                child: const Icon(Icons.calendar_today_outlined, color: AppColors.textoSecundario, size: 16),
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
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _construirCampo(
            label: 'Data Inicial',
            controller: _controllerInicial,
            mascara: _mascaraInicial,
            aoMudar: _aoDigitarInicial,
            aoTocarCalendario: () => _abrirCalendario(inicial: true),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _construirCampo(
            label: 'Data Final',
            controller: _controllerFinal,
            mascara: _mascaraFinal,
            aoMudar: _aoDigitarFinal,
            aoTocarCalendario: () => _abrirCalendario(inicial: false),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controllerInicial.dispose();
    _controllerFinal.dispose();
    super.dispose();
  }
}
