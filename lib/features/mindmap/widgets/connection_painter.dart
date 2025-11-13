import 'package:flutter/material.dart';
import '../models/node_model.dart';
import '../models/connection_model.dart';

class ConnectionPainter extends CustomPainter {
  final List<Node> nodes;
  final List<Connection> connections;

  ConnectionPainter({required this.nodes, required this.connections});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.black
          ..strokeWidth = 2.0;

    for (var conn in connections) {
      final fromNode = nodes.firstWhere((n) => n.id == conn.fromNodeId);
      final toNode = nodes.firstWhere((n) => n.id == conn.toNodeId);
      canvas.drawLine(fromNode.position, toNode.position, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
