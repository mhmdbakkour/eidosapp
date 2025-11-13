import 'package:csci410project/features/mindmap/widgets/radial_menu.dart';

import 'connection_painter.dart';
import 'node_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/node_provider.dart';
import '../providers/connection_provider.dart';
import '../models/node_model.dart';

class MindMapCanvas extends ConsumerStatefulWidget {
  const MindMapCanvas({super.key});

  @override
  ConsumerState<MindMapCanvas> createState() => _MindMapCanvasState();
}

class _MindMapCanvasState extends ConsumerState<MindMapCanvas>
    with TickerProviderStateMixin {
  Offset offset = Offset.zero;
  double scale = 1.0;
  Offset _lastFocalPoint = Offset.zero;

  Node? selectedNode;
  late AnimationController _menuController;

  @override
  void initState() {
    super.initState();
    _menuController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  void _showMenu(Node node) {
    setState(() {
      selectedNode = node;
    });
    _menuController.forward(from: 0);
  }

  void _hideMenu() {
    if (selectedNode != null) {
      _menuController.reverse().then((_) {
        if (mounted) {
          setState(() {
            selectedNode = null;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _menuController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nodes = ref.watch(nodeProvider);
    final connections = ref.watch(connectionProvider);

    return GestureDetector(
      onTapDown: (_) => _hideMenu(),
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
              ...nodes.map(
                (node) => NodeWidget(
                  node: node,
                  onTap: () => _showMenu(node),
                  isMenuActive: selectedNode != null,
                ),
              ),
              if (selectedNode != null)
                RadialMenu(
                  node: selectedNode!,
                  controller: _menuController,
                  onDismiss: _hideMenu,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
