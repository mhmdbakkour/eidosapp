class Connection {
  final String id;
  final String fromNodeId;
  final String toNodeId;

  const Connection({
    required this.id,
    required this.fromNodeId,
    required this.toNodeId,
  });

  static Connection empty() {
    return Connection(id: '', fromNodeId: '', toNodeId: '');
  }

  Connection copyWith({String? id, String? fromNodeId, String? toNodeId}) {
    return Connection(
      id: id ?? this.id,
      fromNodeId: fromNodeId ?? this.fromNodeId,
      toNodeId: toNodeId ?? this.toNodeId,
    );
  }
}
