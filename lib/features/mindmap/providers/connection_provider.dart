import 'package:hive/hive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/connection_model.dart';

class ConnectionNotifier extends Notifier<Map<String, Connection>> {
  late final Box<Connection> _box;

  @override
  Map<String, Connection> build() {
    _box = Hive.box('connectionsBox');

    final loaded = <String, Connection>{};
    for (final key in _box.keys) {
      final connection = _box.get(key);
      if (connection != null) loaded[key as String] = connection;
    }

    return loaded;
  }

  Future<void> addConnection(Connection connection) async {
    state = {...state, connection.id: connection};
    await _box.put(connection.id, connection);
  }

  Future<void> removeConnection(String id) async {
    final newState = Map<String, Connection>.from(state)..remove(id);
    state = newState;
    await _box.delete(id);
  }
}

final connectionProvider =
    NotifierProvider<ConnectionNotifier, Map<String, Connection>>(
      () => ConnectionNotifier(),
    );
