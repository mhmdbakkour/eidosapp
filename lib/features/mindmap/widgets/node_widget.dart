import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/node_model.dart';
import '../providers/node_provider.dart';

class NodeWidget extends ConsumerStatefulWidget {
  final Node node;
  final VoidCallback? onTap;
  final bool isMenuActive;
  final bool isConnecting;

  const NodeWidget({
    super.key,
    required this.node,
    this.onTap,
    this.isMenuActive = false,
    this.isConnecting = false,
  });

  @override
  ConsumerState<NodeWidget> createState() => _NodeWidgetState();
}

class _NodeWidgetState extends ConsumerState<NodeWidget>
    with SingleTickerProviderStateMixin {
  Offset localOffset = Offset.zero;

  late AnimationController _pulseAnimationController;
  late Animation<double> _curvedAnimation;

  @override
  void initState() {
    super.initState();
    localOffset = widget.node.position;

    _pulseAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _curvedAnimation = CurvedAnimation(
      parent: _pulseAnimationController,
      curve: Curves.elasticInOut,
    );

    if (widget.isConnecting) {
      _pulseAnimationController.forward();
    }
  }

  @override
  void didUpdateWidget(covariant NodeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.node.id != widget.node.id) {
      localOffset = widget.node.position;
    }

    if (widget.isConnecting && !oldWidget.isConnecting) {
      _pulseAnimationController.repeat(reverse: true);
    }

    if (!widget.isConnecting && oldWidget.isConnecting) {
      _pulseAnimationController.stop();
      _pulseAnimationController.reset();
    }
  }

  @override
  void dispose() {
    _pulseAnimationController.dispose();
    super.dispose();
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
            final scale = 1.0 + (_curvedAnimation.value * 0.1);
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
