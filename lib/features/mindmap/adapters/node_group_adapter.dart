import 'package:csci410project/features/mindmap/models/node_group_model.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class NodeGroupAdapter extends TypeAdapter<NodeGroup> {
  @override
  final int typeId = 2;

  @override
  NodeGroup read(BinaryReader reader) {
    final id = reader.readString();
    final title = reader.readString();
    final offsetX = reader.readDouble();
    final offsetY = reader.readDouble();
    final width = reader.readDouble();
    final height = reader.readDouble();
    final color = reader.readString();

    final translatedColor;

    switch (color) {
      case "Red":
        translatedColor = Colors.red;
        break;
      case "Orange":
        translatedColor = Colors.orange;
        break;
      case "Green":
        translatedColor = Colors.green;
        break;
      case "Purple":
        translatedColor = Colors.purple;
        break;
      case "Yellow":
        translatedColor = Colors.yellow.shade700;
        break;
      case "Pink":
        translatedColor = Colors.pink;
        break;
      default:
        translatedColor = Colors.blue;
    }

    return NodeGroup(
      id: id,
      title: title,
      position: Offset(offsetX, offsetY),
      color: translatedColor,
      size: Size(width, height),
    );
  }

  @override
  void write(BinaryWriter writer, NodeGroup group) {
    final translatedColor;

    switch (group.color) {
      case Colors.red:
        translatedColor = "Red";
        break;
      case Colors.orange:
        translatedColor = "Orange";
        break;
      case Colors.green:
        translatedColor = "Green";
        break;
      case Colors.purple:
        translatedColor = "Purple";
        break;
      case Colors.blue:
        translatedColor = "Blue";
        break;
      default:
        translatedColor = "Yellow";
    }

    writer.writeString(group.id);
    writer.writeString(group.title);
    writer.writeDouble(group.position.dx);
    writer.writeDouble(group.position.dy);
    writer.writeDouble(group.size.width);
    writer.writeDouble(group.size.height);
    writer.writeString(translatedColor);
  }
}
