import 'package:flutter/material.dart';
import 'package:oficina_conectada_front/colors/colors.dart';
import 'package:oficina_conectada_front/strings/oficina_strings.dart';
import 'package:oficina_conectada_front/components/toast/custom_toast.dart';

class CardTabStep {
  final String title;

  final Widget content;

  final bool Function() isStepValid;

  CardTabStep({required this.title, required this.content, required this.isStepValid});
}

class CardTabAnimated extends StatefulWidget {


  final List<CardTabStep> steps;

  final Color activeColor;

  final double height;

  final int initialStep;

  const CardTabAnimated({
    super.key,
    required this.steps,
    this.activeColor = ColorsApp.preto,
    this.height = 450,
    this.initialStep = 0,
  });

  @override
  State<CardTabAnimated> createState() => CardTabAnimatedState();
}

class CardTabAnimatedState extends State<CardTabAnimated> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialStep;
  }

  void goToStep(int index) {
    if (index > 0 && !widget.steps[index - 1].isStepValid()) {
      CustomToast.show(
        context,
        message: OficinaStrings.porFavorPreenchaOsCamposObrigatorios,
        type: ToastType.warning,
      );
      return;
    }
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: ColorsApp.preto,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ColorsApp.branco.withOpacity(0.1)),
      ),
      child: Column(children: [_buildHeader(), _buildContent()]),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(widget.steps.length, (index) {
          final isStepEnabled = index == 0 || (index > 0 && widget.steps[index - 1].isStepValid());

          return Expanded(
            child: GestureDetector(
              onTap: isStepEnabled ? () => goToStep(index) : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _currentIndex == index ? widget.activeColor : ColorsApp.transparente,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    style: TextStyle(
                      color: isStepEnabled
                          ? (_currentIndex == index ? ColorsApp.branco : ColorsApp.preto)
                          : Colors.grey.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                    child: Text(widget.steps[index].title.toUpperCase()),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildContent() {
    return Expanded(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        transitionBuilder: (child, animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: Container(
          key: ValueKey<int>(_currentIndex),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: widget.steps[_currentIndex].content,
        ),
      ),
    );
  }
}
