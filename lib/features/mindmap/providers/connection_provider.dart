import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/connection_model.dart';

class ConnectionNotifier extends Notifier<List<Connection>> {
  @override
  List<Connection> build() {
    return [];
  }

  void addConnection(Connection connection) {
    state = [...state, connection];
  }

  void removeConnection(String id) {
    state = state.where((c) => c.id != id).toList();
  }
}

final connectionProvider =
    NotifierProvider<ConnectionNotifier, List<Connection>>(
      () => ConnectionNotifier(),
    );
