import 'package:csci410project/features/mindmap/models/connection_model.dart';
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
  Node? _nodeToConnect;
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

  void _deleteNode(Node node) {
    ref.read(nodeProvider.notifier).removeNode(node.id);

    final connections = ref.read(connectionProvider);
    for (var conn
        in connections
            .where((c) => c.fromNodeId == node.id || c.toNodeId == node.id)
            .toList()) {
      ref.read(connectionProvider.notifier).removeConnection(conn.id);
    }

    _hideMenu();
  }

  void _editNode(Node node) async {
    final newTextController = TextEditingController(text: node.text);

    final newText = await showDialog<String>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Edit Node'),
            content: TextFormField(
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Text'),
              controller: newTextController,
              maxLength: 10,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, newTextController.text),
                child: const Text("Save"),
              ),
            ],
          ),
    );
    if (newText != null && newText.isNotEmpty) {
      ref.read(nodeProvider.notifier).updateNode(node.copyWith(text: newText));
    }

    _hideMenu();
  }

  void _startConnect(Node node) {
    _nodeToConnect = node;
    _hideMenu();
  }

  void _onNodeTap(Node tappedNode) {
    if (_nodeToConnect != null && _nodeToConnect!.id != tappedNode.id) {
      final connections = ref.read(connectionProvider);

      final existing = connections.firstWhere(
        (c) =>
            (c.fromNodeId == _nodeToConnect!.id &&
                c.toNodeId == tappedNode.id) ||
            (c.toNodeId == _nodeToConnect!.id && c.toNodeId == tappedNode.id),
        orElse: () => Connection.empty(),
      );

      if (existing.id.isNotEmpty) {
        ref.read(connectionProvider.notifier).removeConnection(existing.id);
      } else {
        final newConnection = Connection(
          id: UniqueKey().toString(),
          fromNodeId: _nodeToConnect!.id,
          toNodeId: tappedNode.id,
        );
        ref.read(connectionProvider.notifier).addConnection(newConnection);
      }
      _nodeToConnect = null;
    } else {
      _showMenu(tappedNode);
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
                  onTap: () => _onNodeTap(node),
                  isMenuActive: selectedNode != null,
                ),
              ),
              if (selectedNode != null)
                RadialMenu(
                  node: selectedNode!,
                  controller: _menuController,
                  onDismiss: _hideMenu,
                  onConnect: () => _startConnect(selectedNode!),
                  onDelete: () => _deleteNode(selectedNode!),
                  onEdit: () => _editNode(selectedNode!),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
