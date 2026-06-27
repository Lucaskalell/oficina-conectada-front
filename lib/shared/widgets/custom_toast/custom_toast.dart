import 'package:flutter/material.dart';
import 'package:oficina_conectada_front/core/constants/app_colors.dart';

enum ToastType { sucesso, atencao, erro }

class CustomToast {
  static OverlayEntry? _overlayEntry;

  static void show(
    BuildContext context, {
    required String message,
    required ToastType type,
  }) {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 50,
        right: 20,
        child: _ToastAnimacao(
          mensagem: message,
          tipo: type,
          aoFechar: () {
            if (_overlayEntry != null) {
              _overlayEntry!.remove();
              _overlayEntry = null;
            }
          },
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }
}

class _ToastAnimacao extends StatefulWidget {
  final String mensagem;
  final ToastType tipo;
  final VoidCallback aoFechar;

  const _ToastAnimacao({
    required this.mensagem,
    required this.tipo,
    required this.aoFechar,
  });

  @override
  State<_ToastAnimacao> createState() => _ToastAnimacaoState();
}

class _ToastAnimacaoState extends State<_ToastAnimacao>
    with SingleTickerProviderStateMixin {
  late AnimationController _animacaoController;
  late Animation<Offset> _animacaoSlide;
  late Animation<double> _animacaoFade;

  @override
  void initState() {
    super.initState();
    _animacaoController = AnimationController(
      duration: const Duration(milliseconds: 600),
      reverseDuration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _animacaoSlide = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animacaoController, curve: Curves.elasticOut));

    _animacaoFade = CurvedAnimation(parent: _animacaoController, curve: Curves.easeIn);

    _animacaoController.forward();

    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        _animacaoController.reverse().then((_) => widget.aoFechar());
      }
    });
  }

  @override
  void dispose() {
    _animacaoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color corBorda;
    final IconData icone;
    final String titulo;

    switch (widget.tipo) {
      case ToastType.sucesso:
        corBorda = AppColors.toastSucesso;
        icone = Icons.check_circle;
        titulo = 'SUCESSO';
        break;
      case ToastType.atencao:
        corBorda = AppColors.toastAtencao;
        icone = Icons.warning_amber;
        titulo = 'ATENÇÃO';
        break;
      case ToastType.erro:
        corBorda = AppColors.toastErro;
        icone = Icons.error_outline;
        titulo = 'ERRO';
        break;
    }

    return Material(
      color: Colors.transparent,
      child: SlideTransition(
        position: _animacaoSlide,
        child: FadeTransition(
          opacity: _animacaoFade,
          child: Container(
            width: 350,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: corBorda.withValues(alpha: 0.5), width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icone, color: corBorda, size: 28),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        titulo,
                        style: TextStyle(
                          color: corBorda,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.mensagem,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
