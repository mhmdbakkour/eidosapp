import 'package:flutter/material.dart';

class NodeGroup {
  final String id;
  final Offset position;
  final String title;
  final Color color;
  final Size size;
  final BoxShape shape;

  const NodeGroup({
    required this.id,
    required this.position,
    this.title = '',
    this.color = Colors.lightBlue,
    this.size = const Size(60, 60),
    this.shape = BoxShape.circle,
  });

  NodeGroup copyWith({
    String? id,
    Offset? position,
    String? text,
    Color? color,
    Size? size,
    BoxShape? shape,
  }) {
    return NodeGroup(
      id: id ?? this.id,
      position: position ?? this.position,
      title: text ?? this.title,
      color: color ?? this.color,
      size: size ?? this.size,
      shape: shape ?? this.shape,
    );
  }
}
