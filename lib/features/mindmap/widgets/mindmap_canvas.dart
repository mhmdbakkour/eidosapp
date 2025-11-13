import 'package:csci410project/features/mindmap/widgets/connection_painter.dart';
import 'package:csci410project/features/mindmap/widgets/node_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/node_provider.dart';
import '../providers/connection_provider.dart';

class MindMapCanvas extends ConsumerStatefulWidget {
  const MindMapCanvas({super.key});

  @override
  ConsumerState<MindMapCanvas> createState() => _MindMapCanvasState();
}

class _MindMapCanvasState extends ConsumerState<MindMapCanvas> {
  Offset offset = Offset.zero;
  double scale = 1.0;
  Offset _lastFocalPoint = Offset.zero;

  @override
  Widget build(BuildContext context) {
    final nodes = ref.watch(nodeProvider);
    final connections = ref.watch(connectionProvider);
    return GestureDetector(
      onScaleStart: (details) {
        _lastFocalPoint = details.focalPoint;
      },
      onScaleUpdate: (details) {
        setState(() {
          scale *= details.scale;
          offset += details.focalPoint - _lastFocalPoint;
          _lastFocalPoint = details.focalPoint;
        });
      },
      child: ClipRect(
        child: Transform(
          transform:
              Matrix4.identity()
                ..translate(offset.dx, offset.dy)
                ..scale(scale),
          child: Stack(
            children: [
              CustomPaint(
                size: Size.infinite,
                painter: ConnectionPainter(
                  nodes: nodes,
                  connections: connections,
                ),
              ),
              ...nodes.map((node) => NodeWidget(node: node)),
            ],
          ),
        ),
      ),
    );
  }
}
