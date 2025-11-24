import 'package:csci410project/features/mindmap/dialogs/node_group_dialog.dart';
import 'package:csci410project/features/mindmap/models/connection_model.dart';
import 'package:csci410project/features/mindmap/models/node_group_model.dart';
import 'package:csci410project/features/mindmap/providers/node_group_provider.dart';
import 'package:csci410project/features/mindmap/providers/theme_provider.dart';
import 'package:csci410project/features/mindmap/widgets/grid_painter.dart';
import 'package:csci410project/features/mindmap/widgets/node_group_widget.dart';
import 'package:csci410project/features/mindmap/widgets/radial_menu.dart';
import 'package:uuid/uuid.dart';

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
  late TransformationController _viewportController;
  bool controlsVisible = false;

  @override
  void initState() {
    super.initState();
    _menuController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _viewportController = TransformationController();

    const canvasSize = Size(50000, 50000);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenSize = MediaQuery.of(context).size;

      final dx = (screenSize.width / 2) - (canvasSize.width / 2);
      final dy = (screenSize.height / 2) - (canvasSize.height / 2);

      _viewportController.value = Matrix4.identity()..translate(dx, dy);
    });
  }

  void _showMenu(String nodeId) {
    final node = ref.read(nodeProvider.select((nodes) => nodes[nodeId]));
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

      final finalNode = newNodeData.copyWith(position: canvasCenter);

      ref.read(nodeProvider.notifier).addNode(finalNode);
      setState(() {});
    }
  }

  void _addNodeGroup() async {
    final newNodeGroupData = await showDialog<NodeGroup>(
      context: context,
      builder: (_) => const NodeGroupDialog(dialogText: "Create new group"),
    );

    if (newNodeGroupData != null) {
      final screenSize = MediaQuery.of(context).size;
      final invertedMatrix = Matrix4.inverted(_viewportController.value);
      final canvasCenter = MatrixUtils.transformPoint(
        invertedMatrix,
        Offset(screenSize.width / 2, screenSize.height / 2),
      );

      final finalNodeGroup = newNodeGroupData.copyWith(position: canvasCenter);

      ref.read(nodeGroupProvider.notifier).addNodeGroup(finalNodeGroup);
    }
    setState(() {});
  }

  void _deleteNode(String nodeId) {
    _hideMenu();
    ref.read(nodeProvider.notifier).removeNode(nodeId);

    final connections = ref.read(connectionProvider).values.toList();
    for (var conn
        in connections
            .where((c) => c.fromNodeId == nodeId || c.toNodeId == nodeId)
            .toList()) {
      ref.read(connectionProvider.notifier).removeConnection(conn.id);
    }
    setState(() {});
  }

  void _deleteNodeGroup(String nodeGroupId) {
    final nodeGroup = ref
        .read(nodeGroupProvider)
        .values
        .firstWhere((g) => g.id == nodeGroupId);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Group'),
          content: const Text('Are you sure you want to delete this group?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () {
                ref
                    .read(nodeGroupProvider.notifier)
                    .removeNodeGroup(nodeGroup.id);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
    setState(() {});
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

    setState(() {});
  }

  void _editNodeGroup(String nodeGroupId) async {
    final nodeGroup = ref
        .read(nodeGroupProvider)
        .values
        .firstWhere((g) => g.id == nodeGroupId);

    final editedNodeGroup = await showDialog<NodeGroup>(
      context: context,
      builder:
          (_) =>
              NodeGroupDialog(dialogText: "Edit group", nodeGroup: nodeGroup),
    );

    if (editedNodeGroup != null) {
      ref.read(nodeGroupProvider.notifier).updateNodeGroup(editedNodeGroup);
    }

    setState(() {});
  }

  void _startConnect(Node node) {
    _nodeToConnect = node;
    _hideMenu();
  }

  void _onNodeTap(String tappedNodeId) {
    if (_nodeToConnect != null && _nodeToConnect!.id != tappedNodeId) {
      final connections = ref.read(connectionProvider).values.toList();

      final existing = connections.firstWhere(
        (c) =>
            (c.fromNodeId == _nodeToConnect!.id &&
                c.toNodeId == tappedNodeId) ||
            (c.toNodeId == _nodeToConnect!.id && c.fromNodeId == tappedNodeId),
        orElse: () => Connection.empty(),
      );

      if (existing.id.isNotEmpty) {
        ref.read(connectionProvider.notifier).removeConnection(existing.id);
      } else {
        final newConnection = Connection(
          id: Uuid().v4(),
          fromNodeId: _nodeToConnect!.id,
          toNodeId: tappedNodeId,
        );
        ref.read(connectionProvider.notifier).addConnection(newConnection);
      }
      _nodeToConnect = null;
    } else {
      _showMenu(tappedNodeId);
    }
    setState(() {});
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nodeIds = ref.read(nodeProvider).keys.toList();
    final connectionIds = ref.read(connectionProvider).keys.toList();
    final nodeGroupIds = ref.read(nodeGroupProvider).keys.toList();
    final bool isDarkMode = ref.watch(themeProvider) == ThemeMode.dark;

    Size canvasSize = Size(50000, 50000);

    return Container(
      color: isDarkMode ? Color(0xff1e1e1e) : Color(0xffdfdfdf),
      child: Stack(
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
                      AnimatedConnections(
                        nodeIds: nodeIds,
                        connectionIds: connectionIds,
                      ),
                      for (final id in nodeGroupIds)
                        NodeGroupWidget(
                          nodeGroupId: id,
                          onEdit: () => _editNodeGroup(id),
                          onDelete: () => _deleteNodeGroup(id),
                        ),
                      for (final id in nodeIds)
                        NodeWidget(
                          nodeId: id,
                          onTap: () => _onNodeTap(id),
                          isMenuActive: selectedNode != null,
                          isConnecting:
                              _nodeToConnect != null
                                  ? _nodeToConnect!.id == id
                                  : false,
                        ),
                      if (selectedNode != null)
                        RadialMenu(
                          node: selectedNode!,
                          controller: _menuController,
                          onDismiss: _hideMenu,
                          onConnect: () => _startConnect(selectedNode!),
                          onDelete: () => _deleteNode(selectedNode!.id),
                          onEdit: () => _editNode(selectedNode!),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            child: IconButton(
              icon: Icon(
                controlsVisible ? Icons.menu_open : Icons.menu,
                color: isDarkMode ? Colors.white : null,
              ),
              onPressed:
                  () => setState(() {
                    controlsVisible = !controlsVisible;
                  }),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            top: 25,
            right: controlsVisible ? 25 : -180,
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
                  height: 3,
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.white : Colors.black54,
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
                  onPressed: _addNodeGroup,
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
      ),
    );
  }
}
