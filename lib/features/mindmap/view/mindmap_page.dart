import 'package:csci410project/features/mindmap/providers/node_group_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:uuid/uuid.dart';
import '../models/node_group_model.dart';
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

      WidgetsBinding.instance.addPostFrameCallback((_) {
        final nodeNotifier = ref.read(nodeProvider.notifier);
        final connectionNotifier = ref.read(connectionProvider.notifier);
        final nodeGroupNotifier = ref.read(nodeGroupProvider.notifier);
        final uuid = Uuid();
        final nodeIDs = [uuid.v4(), uuid.v4(), uuid.v4(), uuid.v4()];

        if (ref.read(nodeProvider).isEmpty) {
          nodeNotifier.addNode(
            Node(
              id: nodeIDs[0],
              text: 'Node 1',
              position: const Offset(25100, 25100),
              color: Colors.blue,
            ),
          );
          nodeNotifier.addNode(
            Node(
              id: nodeIDs[1],
              text: 'Node 2',
              position: const Offset(25250, 25200),
              color: Colors.red,
              shape: BoxShape.rectangle,
            ),
          );
          nodeNotifier.addNode(
            Node(
              id: nodeIDs[2],
              text: 'Node 3',
              position: const Offset(25150, 25175),
              color: Colors.green,
            ),
          );
          nodeNotifier.addNode(
            Node(
              id: nodeIDs[3],
              text: 'Node 4',
              position: const Offset(25300, 25300),
              color: Colors.orange,
              size: 80.0,
            ),
          );

          connectionNotifier.addConnection(
            Connection(
              id: uuid.v4(),
              fromNodeId: nodeIDs[0],
              toNodeId: nodeIDs[1],
            ),
          );
          connectionNotifier.addConnection(
            Connection(
              id: uuid.v4(),
              fromNodeId: nodeIDs[1],
              toNodeId: nodeIDs[2],
            ),
          );
          connectionNotifier.addConnection(
            Connection(
              id: uuid.v4(),
              fromNodeId: nodeIDs[0],
              toNodeId: nodeIDs[2],
            ),
          );
        }

        if (ref.read(nodeGroupProvider).isEmpty) {
          nodeGroupNotifier.addNodeGroup(
            NodeGroup(
              id: uuid.v4(),
              title: "Mobile Development",
              position: Offset(25000, 25000),
              color: Colors.blue,
              size: Size(800, 600),
            ),
          );
          nodeGroupNotifier.addNodeGroup(
            NodeGroup(
              id: uuid.v4(),
              title: "Operating Systems",
              position: Offset(25600, 25600),
              size: Size(600, 600),
              color: Colors.purple,
            ),
          );
          nodeGroupNotifier.addNodeGroup(
            NodeGroup(
              id: uuid.v4(),
              title: "Operating Systems Lab",
              position: Offset(24500, 25000),
              size: Size(300, 500),
              color: Colors.yellow.shade700,
            ),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            SvgPicture.asset(
              r'C:\Users\Workspace\StudioProjects\csci410project\lib\assets\Eidos.svg',
              height: 40,
              width: 40,
            ),
            const SizedBox(width: 10),
            const Text("Eidos"),
          ],
        ),
        backgroundColor: Color(0xff1e1e1e),
        foregroundColor: Colors.white,
      ),
      body: const MindMapCanvas(),
    );
  }
}
