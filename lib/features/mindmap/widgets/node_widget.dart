import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/node_model.dart';
import '../providers/node_provider.dart';

class NodeWidget extends ConsumerStatefulWidget {
  final Node node;
  final VoidCallback? onTap;
  final bool isMenuActive;

  const NodeWidget({
    super.key,
    required this.node,
    this.onTap,
    this.isMenuActive = false,
  });

  @override
  ConsumerState<NodeWidget> createState() => _NodeWidgetState();
}

class _NodeWidgetState extends ConsumerState<NodeWidget> {
  Offset localOffset = Offset.zero;

  @override
  void initState() {
    super.initState();
    localOffset = widget.node.position;
  }

  @override
  void didUpdateWidget(covariant NodeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.node.id != widget.node.id) {
      localOffset = widget.node.position;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.node.position.dx - 30,
      top: widget.node.position.dy - 30,
      child: GestureDetector(
        onPanUpdate:
            widget.isMenuActive
                ? null
                : (details) {
                  setState(() {
                    localOffset += details.delta;
                  });
                  ref
                      .read(nodeProvider.notifier)
                      .updateNode(widget.node.copyWith(position: localOffset));
                },
        onTap: widget.onTap,
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: widget.node.color,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            widget.node.text,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
