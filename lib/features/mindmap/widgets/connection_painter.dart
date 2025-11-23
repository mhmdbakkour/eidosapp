import 'package:csci410project/features/mindmap/providers/node_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/connection_model.dart';
import '../models/node_model.dart';
import '../providers/connection_provider.dart';

class AnimatedConnections extends ConsumerStatefulWidget {
  final List<String> nodeIds;
  final List<String> connectionIds;

  const AnimatedConnections({
    super.key,
    required this.nodeIds,
    required this.connectionIds,
  });

  @override
  ConsumerState<AnimatedConnections> createState() =>
      _AnimatedConnectionsState();
}

class _AnimatedConnectionsState extends ConsumerState<AnimatedConnections>
    with TickerProviderStateMixin {
  final Map<String, Animation<double>> _animations = {};
  final Map<String, AnimationController> _animationControllers = {};
  final Map<String, Connection> _reversingConnectionsData = {};

  @override
  void didUpdateWidget(covariant AnimatedConnections oldWidget) {
    super.didUpdateWidget(oldWidget);

    final allConnections = ref.read(connectionProvider);
    final oldConnectionIdsSet = oldWidget.connectionIds.toSet();
    final newConnectionIdsSet = widget.connectionIds.toSet();

    final addedConnectionIds = newConnectionIdsSet.difference(
      oldConnectionIdsSet,
    );

    for (var connectionId in addedConnectionIds) {
      if (!_animationControllers.containsKey(connectionId)) {
        final controller = AnimationController(
          duration: const Duration(milliseconds: 400),
          vsync: this,
        );

        final curvedAnimation = CurvedAnimation(
          parent: controller,
          curve: Curves.easeOutExpo,
        );

        _animationControllers[connectionId] = controller;
        _animations[connectionId] = curvedAnimation;

        if (_reversingConnectionsData.containsKey(connectionId)) {
          _reversingConnectionsData.remove(connectionId);
          controller.forward(from: controller.value);
        } else {
          controller.forward();
        }
      }
    }

    final removedConnectionIds = oldConnectionIdsSet.difference(
      newConnectionIdsSet,
    );

    for (final connectionId in removedConnectionIds) {
      final controller = _animationControllers[connectionId];
      final connectionData = allConnections.values.firstWhere(
        (c) => c.id == connectionId,
        orElse: () => Connection.empty(),
      );

      if (controller != null && connectionData.id.isNotEmpty) {
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
    final allNodes = ref.watch(nodeProvider);
    final relevantNodes =
        widget.nodeIds.map((id) => allNodes[id]).whereType<Node>().toList();

    final allConnections = ref.watch(connectionProvider);
    final liveConnections =
        allConnections.values
            .where((c) => widget.connectionIds.contains(c.id))
            .toList();

    final repaint = Listenable.merge(_animationControllers.values.toList());

    return CustomPaint(
      painter: _ConnectionPainter(
        nodes: relevantNodes,
        liveConnections: liveConnections,
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
          ..color = Colors.black
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
