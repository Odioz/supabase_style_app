import 'package:flutter/material.dart';

/// Ограничивает ширину контента на больших экранах,
/// но не мешает на смартфонах (там maxWidth больше ширины экрана).
class ContentWidth extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;

  const ContentWidth({
    super.key,
    required this.child,
    this.maxWidth = 900,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}