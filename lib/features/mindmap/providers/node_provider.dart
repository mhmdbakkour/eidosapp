import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/node_model.dart';

// Extend Notifier instead of StateNotifier
class NodeNotifier extends Notifier<List<Node>> {
  @override
  List<Node> build() {
    return [];
  }

  void addNode(Node node) {
    state = [...state, node];
  }

  void updateNode(Node updated) {
    state = [
      for (final n in state)
        if (n.id == updated.id) updated else n,
    ];
  }

  void removeNode(String id) {
    state = state.where((n) => n.id != id).toList();
  }
}

final nodeProvider = NotifierProvider<NodeNotifier, List<Node>>(
  () => NodeNotifier(),
);
