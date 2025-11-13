import 'package:flutter/material.dart';

class Node {
  final String id;
  final Offset position;
  final String text;
  final Color color;

  const Node({
    required this.id,
    required this.position,
    this.text = '',
    this.color = Colors.lightBlue,
  });

  Node copyWith({String? id, Offset? position, String? text, Color? color}) {
    return Node(
      id: id ?? this.id,
      position: position ?? this.position,
      text: text ?? this.text,
      color: color ?? this.color,
    );
  }
}
