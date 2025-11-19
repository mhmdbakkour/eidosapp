import 'package:csci410project/features/mindmap/models/connection_model.dart';
import 'package:csci410project/features/mindmap/widgets/grid_painter.dart';
import 'package:csci410project/features/mindmap/widgets/node_group_widget.dart';
import 'package:csci410project/features/mindmap/widgets/radial_menu.dart';

import '../dialogs/node_dialog.dart';
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
  Node? selectedNode;
  Node? _nodeToConnect;
  late AnimationController _menuController;
  late AnimationController _connectionPulseController;
  late TransformationController _viewportController;

  @override
  void initState() {
    super.initState();
    _menuController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _connectionPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _viewportController = TransformationController();

    const canvasSize = Size(50000, 50000);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenSize = MediaQuery.of(context).size;

      final dx = (screenSize.width / 2) - (canvasSize.width / 2);
      final dy = (screenSize.height / 2) - (canvasSize.height / 2);

      _viewportController.value = Matrix4.identity()..translate(dx, dy);
    });
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

  void _addNode() async {
    final newNodeData = await showDialog<Node>(
      context: context,
      builder: (_) => const NodeDialog(dialogText: "Create new node"),
    );

    if (newNodeData != null) {
      final screenSize = MediaQuery.of(context).size;
      final invertedMatrix = Matrix4.inverted(_viewportController.value);
      final canvasCenter = MatrixUtils.transformPoint(
        invertedMatrix,
        Offset(screenSize.width / 2, screenSize.height / 2),
      );

      // Create the final node with the correct position
      final finalNode = newNodeData.copyWith(position: canvasCenter);

      ref.read(nodeProvider.notifier).addNode(finalNode);
    }
  }

  void _deleteNode(Node node) {
    _hideMenu();
    ref.read(nodeProvider.notifier).removeNode(node.id);

    final connections = ref.read(connectionProvider);
    for (var conn
        in connections
            .where((c) => c.fromNodeId == node.id || c.toNodeId == node.id)
            .toList()) {
      ref.read(connectionProvider.notifier).removeConnection(conn.id);
    }
  }

  void _editNode(Node node) async {
    _hideMenu();
    final editedNode = await showDialog<Node>(
      context: context,
      builder: (_) => NodeDialog(dialogText: "Edit node", node: node),
    );

    if (editedNode != null) {
      ref.read(nodeProvider.notifier).updateNode(editedNode);
    }
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
            (c.toNodeId == _nodeToConnect!.id && c.fromNodeId == tappedNode.id),
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

  void _centerCamera() {
    final screenSize = MediaQuery.of(context).size;
    const canvasCenter = Offset(25000, 25000);

    final dx = (screenSize.width / 2) - canvasCenter.dx;
    final dy = (screenSize.height / 2) - canvasCenter.dy;

    final newMatrix = Matrix4.identity()..translate(dx, dy);

    final animation = Matrix4Tween(
      begin: _viewportController.value,
      end: newMatrix,
    ).animate(
      CurvedAnimation(parent: _menuController, curve: Curves.easeInOut),
    );

    void animationListener() {
      _viewportController.value = animation.value;
      if (animation.status == AnimationStatus.completed) {
        animation.removeListener(animationListener);
      }
    }

    animation.addListener(animationListener);

    _menuController.reset();
    _menuController.forward();
  }

  @override
  void dispose() {
    _menuController.dispose();
    _connectionPulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nodes = ref.watch(nodeProvider);
    final connections = ref.watch(connectionProvider);

    Size canvasSize = Size(50000, 50000);

    return Stack(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTapDown: (_) => _hideMenu(),
          child: InteractiveViewer(
            transformationController: _viewportController,
            panEnabled: true,
            scaleEnabled: true,
            minScale: 0.2,
            maxScale: 4,
            constrained: false,
            clipBehavior: Clip.none,
            child: SizedBox(
              width: canvasSize.width,
              height: canvasSize.height,
              child: CustomPaint(
                painter: GridPainter(),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    NodeGroupWidget(
                      key: ValueKey("mobile-dev-group"),
                      title: "Mobile Development",
                      position: Offset(25000, 25000),
                      size: Size(600, 400),
                      color: Colors.blue,
                    ),
                    NodeGroupWidget(
                      key: ValueKey("operating-systems-group"),
                      title: "Operating Systems",
                      position: Offset(25600, 25600),
                      size: Size(600, 600),
                      color: Colors.purple,
                    ),
                    NodeGroupWidget(
                      key: ValueKey("operating-systems-lab-group"),
                      title: "Operating Systems Lab",
                      position: Offset(24500, 25000),
                      size: Size(300, 500),
                      color: Colors.green,
                    ),
                    CustomPaint(
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
                        isConnecting:
                            _nodeToConnect != null
                                ? _nodeToConnect!.id == node.id
                                : false,
                        pulseAnimation: _connectionPulseController,
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
          ),
        ),
        Positioned(
          top: 25,
          right: 25,
          child: Column(
            children: [
              FilledButton.icon(
                icon: Icon(Icons.flip_camera_android),
                onPressed: _centerCamera,
                label: Text("Back to origin"),
                style: FilledButton.styleFrom(
                  foregroundColor: Colors.greenAccent,
                  backgroundColor: Color(0xff444444),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 10),
              FilledButton.icon(
                icon: Icon(Icons.add_circle),
                onPressed: _addNode,
                label: Text("Add Node"),
                style: FilledButton.styleFrom(
                  foregroundColor: Colors.greenAccent,
                  backgroundColor: Color(0xff444444),
                ),
              ),
              const SizedBox(height: 10),
              FilledButton.icon(
                icon: Icon(Icons.group_work_sharp),
                onPressed: () {},
                label: Text("Add Group"),
                style: FilledButton.styleFrom(
                  foregroundColor: Colors.greenAccent,
                  backgroundColor: Color(0xff444444),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
