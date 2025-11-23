import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../models/node_model.dart';

class NodeNotifier extends Notifier<Map<String, Node>> {
  late final Box<Node> _box;

  @override
  Map<String, Node> build() {
    _box = Hive.box<Node>('nodesBox');

    final loaded = <String, Node>{};
    for (final key in _box.keys) {
      final node = _box.get(key);
      if (node != null) loaded[key as String] = node;
    }

    return loaded;
  }

  Future<void> addNode(Node node) async {
    state = {...state, node.id: node};
    await _box.put(node.id, node);
  }

  Future<void> updateNode(Node updated) async {
    state = {...state, updated.id: updated};
    await _box.put(updated.id, updated);
  }

  Future<void> removeNode(String id) async {
    final newState = Map<String, Node>.from(state)..remove(id);
    state = newState;
    await _box.delete(id);
  }
}

final nodeProvider = NotifierProvider<NodeNotifier, Map<String, Node>>(
  () => NodeNotifier(),
);
