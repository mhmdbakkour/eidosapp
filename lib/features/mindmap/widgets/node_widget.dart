import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/node_model.dart';
import '../providers/node_provider.dart';

class NodeWidget extends ConsumerStatefulWidget {
  final Node node;
  final VoidCallback? onTap;
  final bool isMenuActive;
  final bool isConnecting;
  final Animation<double> pulseAnimation;

  const NodeWidget({
    super.key,
    required this.node,
    this.onTap,
    this.isMenuActive = false,
    this.isConnecting = false,
    required this.pulseAnimation,
  });

  @override
  ConsumerState<NodeWidget> createState() => _NodeWidgetState();
}

class _NodeWidgetState extends ConsumerState<NodeWidget> {
  Offset localOffset = Offset.zero;

  late CurvedAnimation _curvedAnimation = CurvedAnimation(
    parent: widget.pulseAnimation,
    curve: Curves.elasticInOut,
  );

  @override
  void initState() {
    super.initState();
    localOffset = widget.node.position;

    _curvedAnimation = CurvedAnimation(
      parent: widget.pulseAnimation,
      curve: Curves.elasticInOut,
    );
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
      left: widget.node.position.dx - widget.node.size / 2,
      top: widget.node.position.dy - widget.node.size / 2,
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
        onTap: widget.isMenuActive ? null : widget.onTap,
        child: AnimatedBuilder(
          animation: _curvedAnimation,
          builder: (context, child) {
            final scale =
                widget.isConnecting
                    ? 1.0 + (_curvedAnimation.value * 0.1)
                    : 1.0;
            return Transform.scale(
              scale: scale,
              child: Container(
                width: widget.node.size,
                height: widget.node.size,
                decoration: BoxDecoration(
                  color: widget.node.color,
                  shape: widget.node.shape,
                  border:
                      widget.isConnecting
                          ? Border.all(color: Colors.black, width: 2)
                          : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  widget.node.text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize:
                        widget.node.size > 60
                            ? 16
                            : widget.node.size > 40
                            ? 12
                            : 8,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
