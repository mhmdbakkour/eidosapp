import 'package:flutter/material.dart';

class GridPainter extends CustomPainter {
  GridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const minorSpacing = 100.0;
    const majorSpacing = 1000.0;

    final minor = minorSpacing;
    final major = majorSpacing;

    final minorPaint =
        Paint()
          ..color = Colors.grey.withValues(alpha: 0.25 * 255)
          ..strokeWidth = 1.0;

    final majorPaint =
        Paint()
          ..color = Colors.grey.withValues(alpha: 0.55 * 255)
          ..strokeWidth = 1.5;

    for (double x = 0; x <= size.width; x += minor) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), minorPaint);
    }
    for (double y = 0; y <= size.height; y += minor) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), minorPaint);
    }

    // Draw major grid
    for (double x = 0; x <= size.width; x += major) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), majorPaint);
    }
    for (double y = 0; y <= size.height; y += major) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), majorPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
