import 'package:flutter/material.dart';

class NodeGroupWidget extends StatefulWidget {
  final String? title;
  final Color color;
  final Offset position;
  final Size size;

  const NodeGroupWidget({
    super.key,
    required this.title,
    this.color = Colors.black,
    required this.position,
    required this.size,
  });

  @override
  State<NodeGroupWidget> createState() => _NodeGroupWidgetState();
}

class _NodeGroupWidgetState extends State<NodeGroupWidget> {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.position.dx - widget.size.width / 2,
      top: widget.position.dy - widget.size.height / 2,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: widget.color.withAlpha(30),
              border: Border.all(color: widget.color),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              widget.title ?? "Group",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 4),
          Container(
            width: widget.size.width,
            height: widget.size.height,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: widget.color.withAlpha(30),
              border: Border.all(color: widget.color, width: 2.0),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ],
      ),
    );
  }
}
