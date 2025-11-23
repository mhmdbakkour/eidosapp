import 'package:csci410project/features/mindmap/models/connection_model.dart';
import 'package:hive/hive.dart';

class ConnectionAdapter extends TypeAdapter<Connection> {
  @override
  final int typeId = 1;

  @override
  Connection read(BinaryReader reader) {
    final id = reader.readString();
    final fromNodeId = reader.readString();
    final toNodeId = reader.readString();

    return Connection(id: id, fromNodeId: fromNodeId, toNodeId: toNodeId);
  }

  @override
  void write(BinaryWriter writer, Connection connection) {
    writer.writeString(connection.id);
    writer.writeString(connection.fromNodeId);
    writer.writeString(connection.toNodeId);
  }
}
