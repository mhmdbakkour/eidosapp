import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/mindmap_canvas.dart';
import '../models/node_model.dart';
import '../models/connection_model.dart';
import '../providers/node_provider.dart';
import '../providers/connection_provider.dart';

class MindMapPage extends ConsumerStatefulWidget {
  const MindMapPage({super.key});

  @override
  ConsumerState<MindMapPage> createState() => _MindMapPageState();
}

class _MindMapPageState extends ConsumerState<MindMapPage> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;

      // Delay provider updates until after build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final nodeNotifier = ref.read(nodeProvider.notifier);
        final connectionNotifier = ref.read(connectionProvider.notifier);

        // Only add test nodes once
        if (ref.read(nodeProvider).isEmpty) {
          nodeNotifier.addNode(
            Node(
              id: '1',
              text: 'Node 1',
              position: const Offset(100, 100),
              color: Colors.blue,
            ),
          );
          nodeNotifier.addNode(
            Node(
              id: '2',
              text: 'Node 2',
              position: const Offset(250, 200),
              color: Colors.red,
            ),
          );
          nodeNotifier.addNode(
            Node(
              id: '3',
              text: 'Node 3',
              position: const Offset(150, 175),
              color: Colors.green,
            ),
          );

          connectionNotifier.addConnection(
            Connection(id: 'c1', fromNodeId: '1', toNodeId: '2'),
          );
          connectionNotifier.addConnection(
            Connection(id: 'c2', fromNodeId: '2', toNodeId: '3'),
          );
          connectionNotifier.addConnection(
            Connection(id: 'c3', fromNodeId: '1', toNodeId: '3'),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MindMap Test')),
      body: const MindMapCanvas(),
    );
  }
}
