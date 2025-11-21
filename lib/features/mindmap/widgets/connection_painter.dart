import 'package:flutter/material.dart';
import '../models/connection_model.dart';
import '../models/node_model.dart';

class AnimatedConnections extends StatefulWidget {
  final List<Node> nodes;
  final List<Connection> connections;

  const AnimatedConnections({
    super.key,
    required this.nodes,
    required this.connections,
  });

  @override
  State<AnimatedConnections> createState() => _AnimatedConnectionsState();
}

class _AnimatedConnectionsState extends State<AnimatedConnections>
    with TickerProviderStateMixin {
  final Map<String, Animation<double>> _animations = {};
  final Map<String, AnimationController> _animationControllers = {};

  final Map<String, Connection> _reversingConnectionsData = {};

  @override
  void didUpdateWidget(covariant AnimatedConnections oldWidget) {
    super.didUpdateWidget(oldWidget);

    final oldConnectionMap = {for (var c in oldWidget.connections) c.id: c};
    final newConnectionIds = widget.connections.map((c) => c.id).toSet();

    final addedConnections = widget.connections.where(
      (c) => !oldConnectionMap.containsKey(c.id),
    );

    for (var connection in addedConnections) {
      if (!_animationControllers.containsKey(connection.id)) {
        final controller = AnimationController(
          duration: const Duration(milliseconds: 400),
          vsync: this,
        );

        final curvedAnimation = CurvedAnimation(
          parent: controller,
          curve: Curves.easeOutExpo,
        );

        _animationControllers[connection.id] = controller;
        _animations[connection.id] = curvedAnimation;

        if (_reversingConnectionsData.containsKey(connection.id)) {
          _reversingConnectionsData.remove(connection.id);
          controller.forward(from: controller.value);
        } else {
          controller.forward();
        }
      }
    }

    final removedConnectionIds = oldConnectionMap.keys.where(
      (id) => !newConnectionIds.contains(id),
    );

    for (final connectionId in removedConnectionIds) {
      final controller = _animationControllers[connectionId];
      final connectionData = oldConnectionMap[connectionId];

      if (controller != null && connectionData != null) {
        _reversingConnectionsData[connectionId] = connectionData;

        controller.reverse().whenComplete(() {
          if (mounted) {
            _animations.remove(connectionId);
            _animationControllers.remove(connectionId)?.dispose();
            _reversingConnectionsData.remove(connectionId);
          }
        });
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _animationControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repaint = Listenable.merge(_animationControllers.values.toList());

    return CustomPaint(
      painter: _ConnectionPainter(
        nodes: widget.nodes,
        liveConnections: widget.connections,
        reversingConnections: _reversingConnectionsData,
        animations: _animations,
        repaint: repaint,
      ),
    );
  }
}

class _ConnectionPainter extends CustomPainter {
  final List<Node> nodes;
  final List<Connection> liveConnections;
  final Map<String, Connection> reversingConnections;
  final Map<String, Animation<double>> animations;

  _ConnectionPainter({
    required this.nodes,
    required this.liveConnections,
    required this.reversingConnections,
    required this.animations,
    required Listenable repaint,
  }) : super(repaint: repaint);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.grey[700]!
          ..strokeWidth = 2.5
          ..style = PaintingStyle.stroke;

    final nodeMap = {for (var node in nodes) node.id: node};

    final allConnectionsToDraw = [
      ...liveConnections,
      ...reversingConnections.values,
    ];

    for (final connection in allConnectionsToDraw) {
      final fromNode = nodeMap[connection.fromNodeId];
      final toNode = nodeMap[connection.toNodeId];

      if (fromNode != null && toNode != null) {
        final startPoint = fromNode.position;
        final endPoint = toNode.position;

        final path =
            Path()
              ..moveTo(startPoint.dx, startPoint.dy)
              ..lineTo(endPoint.dx, endPoint.dy);

        final animation = animations[connection.id];

        if (animation != null) {
          final pathMetric = path.computeMetrics().first;
          final animatedPath = pathMetric.extractPath(
            0.0,
            pathMetric.length * animation.value,
          );
          canvas.drawPath(animatedPath, paint);
        } else {
          canvas.drawPath(path, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(_ConnectionPainter oldDelegate) {
    return oldDelegate.liveConnections.length != liveConnections.length ||
        oldDelegate.reversingConnections.length != reversingConnections.length;
  }
}
