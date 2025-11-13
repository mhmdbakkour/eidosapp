import 'dart:math' as Math;
import 'package:flutter/material.dart';
import '../models/node_model.dart';

class RadialMenu extends StatelessWidget {
  final Node node;
  final AnimationController controller;
  final VoidCallback onDismiss;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback onConnect;

  const RadialMenu({
    super.key,
    required this.node,
    required this.controller,
    required this.onDismiss,
    required this.onDelete,
    required this.onEdit,
    required this.onConnect,
  });

  @override
  Widget build(BuildContext context) {
    final animation = CurvedAnimation(
      parent: controller,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeOut,
    );

    final buttons = [
      _RadialButton(
        icon: Icons.link,
        color: Colors.blue,
        label: "Connect",
        onTap: onConnect,
      ),
      _RadialButton(
        icon: Icons.edit,
        color: Colors.green,
        label: "Edit",
        onTap: onEdit,
      ),
      _RadialButton(
        icon: Icons.delete,
        color: Colors.red,
        label: "Delete",
        onTap: onDelete,
      ),
    ];

    return AnimatedBuilder(
      animation: animation,
      builder: (_, __) {
        final radius = (90.0 * animation.value).clamp(0.0, 90.0);

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: onDismiss,
              ),
            ),
            IgnorePointer(
              ignoring: controller.isAnimating,
              child: Stack(
                children: List.generate(buttons.length, (i) {
                  final totalButtons = buttons.length;
                  final angleStep = Math.pi / (totalButtons); // spread 180°
                  final angle =
                      -(Math.pi / 3) + i * angleStep; // start at -90° (up)

                  final dx = radius * Math.cos(angle);
                  final dy = radius * Math.sin(angle);

                  return Positioned(
                    left: node.position.dx + dx - 25,
                    top: node.position.dy + dy - 25,
                    child: Opacity(
                      opacity: animation.value.clamp(0.0, 1.0),
                      child: buttons[i],
                    ),
                  );
                }),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _RadialButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback? onTap;

  const _RadialButton({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      shape: const CircleBorder(),
      elevation: 3,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 50,
          height: 50,
          child: Icon(icon, color: Colors.white, size: 24),
        ),
      ),
    );
  }
}
