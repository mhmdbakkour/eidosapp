import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../models/node_model.dart';

class NodeAdapter extends TypeAdapter<Node> {
  @override
  final int typeId = 0;

  @override
  Node read(BinaryReader reader) {
    final id = reader.readString();
    final text = reader.readString();
    final offsetX = reader.readDouble();
    final offsetY = reader.readDouble();
    final color = reader.readString();
    final size = reader.readDouble();
    final shape = reader.readString();

    final MaterialColor translatedColor;

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
        translatedColor = Colors.yellow;
        break;
      case "Pink":
        translatedColor = Colors.pink;
        break;
      default:
        translatedColor = Colors.blue;
    }

    return Node(
      id: id,
      text: text,
      position: Offset(offsetX, offsetY),
      color: translatedColor,
      size: size,
      shape: shape == "Rectangle" ? BoxShape.rectangle : BoxShape.circle,
    );
  }

  @override
  void write(BinaryWriter writer, Node node) {
    final translatedColor;

    switch (node.color) {
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
      case Colors.yellow:
        translatedColor = "Yellow";
        break;
      default:
        translatedColor = "Blue";
    }

    writer.writeString(node.id);
    writer.writeString(node.text);
    writer.writeDouble(node.position.dx);
    writer.writeDouble(node.position.dy);
    writer.writeString(translatedColor);
    writer.writeDouble(node.size);
    writer.writeString(
      node.shape == BoxShape.rectangle ? "Rectangle" : "Circle",
    );
  }
}
