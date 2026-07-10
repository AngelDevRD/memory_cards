import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/memory_card.dart';

/// Renders one card with a real 3D flip (rotateY) driven by an
/// AnimationController, plus a small glow burst when it becomes matched.
class MemoryCardWidget extends StatefulWidget {
  const MemoryCardWidget({super.key, required this.card, required this.onTap});

  final MemoryCard card;
  final VoidCallback onTap;

  @override
  State<MemoryCardWidget> createState() => _MemoryCardWidgetState();
}

class _MemoryCardWidgetState extends State<MemoryCardWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _flipController;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    if (widget.card.isFaceUp) _flipController.value = 1;
  }

  @override
  void didUpdateWidget(covariant MemoryCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.card.isFaceUp && !oldWidget.card.isFaceUp) {
      _flipController.forward();
    } else if (!widget.card.isFaceUp && oldWidget.card.isFaceUp) {
      _flipController.reverse();
    }
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: widget.card.isFaceUp || widget.card.isMatched
          ? null
          : widget.onTap,
      child: AnimatedBuilder(
        animation: _flipController,
        builder: (context, child) {
          final angle = _flipController.value * math.pi;
          final showFront = angle > math.pi / 2;
          final displayAngle = showFront ? angle - math.pi : angle;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(displayAngle),
            child: showFront
                ? _buildFace(colorScheme)
                : _buildBack(colorScheme),
          );
        },
      ),
    );
  }

  Widget _buildBack(ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.4)),
      ),
      child: Icon(
        Icons.question_mark_rounded,
        color: colorScheme.onPrimaryContainer,
      ),
    );
  }

  Widget _buildFace(ColorScheme colorScheme) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: widget.card.isMatched
            ? colorScheme.tertiaryContainer
            : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.card.isMatched
              ? colorScheme.tertiary
              : colorScheme.outlineVariant,
          width: widget.card.isMatched ? 2.5 : 1,
        ),
        boxShadow: widget.card.isMatched
            ? [
                BoxShadow(
                  color: colorScheme.tertiary.withValues(alpha: 0.5),
                  blurRadius: 14,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      alignment: Alignment.center,
      child: Text(widget.card.symbol, style: const TextStyle(fontSize: 28)),
    );
  }
}
