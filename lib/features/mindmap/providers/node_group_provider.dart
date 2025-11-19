import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/node_group_model.dart';

class NodeGroupNotifier extends Notifier<List<NodeGroup>> {
  @override
  List<NodeGroup> build() {
    return [];
  }

  void addNodeGroup(NodeGroup group) {
    state = [...state, group];
  }

  void updateNode(NodeGroup updated) {
    state = [
      for (final g in state)
        if (g.id == updated.id) updated else g,
    ];
  }

  void removeNode(String id) {
    state = state.where((g) => g.id != id).toList();
  }
}

final nodeGroupProvider = NotifierProvider<NodeGroupNotifier, List<NodeGroup>>(
  () => NodeGroupNotifier(),
);
