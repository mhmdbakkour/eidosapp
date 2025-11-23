import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../models/node_group_model.dart';

class NodeGroupNotifier extends Notifier<Map<String, NodeGroup>> {
  late final Box<NodeGroup> _box;

  @override
  Map<String, NodeGroup> build() {
    _box = Hive.box<NodeGroup>('nodeGroupsBox');

    final loaded = <String, NodeGroup>{};
    for (final key in _box.keys) {
      final nodeGroup = _box.get(key);
      if (nodeGroup != null) loaded[key as String] = nodeGroup;
    }

    return loaded;
  }

  Future<void> addNodeGroup(NodeGroup group) async {
    state = {...state, group.id: group};
    await _box.put(group.id, group);
  }

  Future<void> updateNodeGroup(NodeGroup updated) async {
    state = {...state, updated.id: updated};
    await _box.put(updated.id, updated);
  }

  Future<void> removeNodeGroup(String id) async {
    final newState = Map<String, NodeGroup>.from(state)..remove(id);
    state = newState;
    await _box.delete(id);
  }
}

final nodeGroupProvider =
    NotifierProvider<NodeGroupNotifier, Map<String, NodeGroup>>(
      () => NodeGroupNotifier(),
    );
