import 'package:flutter/material.dart';

class TableHeader extends StatelessWidget {
  final String text;
  final int flex;
  final bool center;

  const TableHeader({
    super.key,
    required this.text,
    this.flex = 1,
    this.center = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: center
          ? Center(child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)))
          : Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}

class TableCellText extends StatelessWidget {
  final String text;
  final int flex;

  const TableCellText({
    super.key,
    required this.text,
    this.flex = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(text),
    );
  }
}