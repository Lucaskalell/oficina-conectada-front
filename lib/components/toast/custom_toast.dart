import 'package:flutter/material.dart';
import 'package:oficina_conectada_front/colors/colors.dart';
import 'package:oficina_conectada_front/strings/oficina_strings.dart';

enum ToastType { success, warning, error }

class CustomToast {
  static OverlayEntry? _overlayEntry;

  static void show(BuildContext context, {required String message, required ToastType type}) {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 50,
        right: 20,
        child: _ToastAnimation(
          message: message,
          type: type,
          onDismiss: () {
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

class _ToastAnimation extends StatefulWidget {
  final String message;
  final ToastType type;
  final VoidCallback onDismiss;

  const _ToastAnimation({
    required this.message,
    required this.type,
    required this.onDismiss,
  });

  @override
  State<_ToastAnimation> createState() => _ToastAnimationState();
}

class _ToastAnimationState extends State<_ToastAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      reverseDuration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();

    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        _controller.reverse().then((value) => widget.onDismiss());
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    IconData icon;
    Color borderColor;

    switch (widget.type) {
      case ToastType.success:
        bgColor = const Color(0xFF1E2A1E);
        borderColor = ColorsApp.verdeToast;
        icon = Icons.check_circle;
        break;
      case ToastType.warning:
        bgColor = const Color(0xFF2A2418);
        borderColor = ColorsApp.amareloToast;
        icon = Icons.warning_amber;
        break;
      case ToastType.error:
        bgColor = const Color(0xFF563131);
        borderColor = ColorsApp.vermelhoToast;
        icon = Icons.error_outline;
        break;
    }

    return Material(
      color: Colors.transparent,
      child: SlideTransition(
        position: _offsetAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            width: 350,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor.withOpacity(0.5), width: 1),
              boxShadow: [
                BoxShadow(
                  color: ColorsApp.preto.withOpacity(0.5),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: borderColor, size: 28),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.type == ToastType.error ? OficinaStrings.erro :
                        widget.type == ToastType.warning ? OficinaStrings.atencao : OficinaStrings.sucesso,
                        style: TextStyle(
                            color: borderColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            letterSpacing: 1.2
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.message,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14
                        ),
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