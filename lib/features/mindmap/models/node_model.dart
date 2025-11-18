import 'package:flutter/material.dart';

class Node {
  final String id;
  final Offset position;
  final String text;
  final Color color;
  final double size;
  final BoxShape shape;

  const Node({
    required this.id,
    required this.position,
    this.text = '',
    this.color = Colors.lightBlue,
    this.size = 60.0,
    this.shape = BoxShape.circle,
  });

  Node copyWith({
    String? id,
    Offset? position,
    String? text,
    Color? color,
    double? size,
    BoxShape? shape,
  }) {
    return Node(
      id: id ?? this.id,
      position: position ?? this.position,
      text: text ?? this.text,
      color: color ?? this.color,
      size: size ?? this.size,
      shape: shape ?? this.shape,
    );
  }
}
