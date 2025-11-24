import 'package:csci410project/features/mindmap/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/node_provider.dart';

class NodeWidget extends ConsumerStatefulWidget {
  final String nodeId;
  final VoidCallback? onTap;
  final bool isMenuActive;
  final bool isConnecting;

  const NodeWidget({
    super.key,
    required this.nodeId,
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

    final node = ref.read(nodeProvider)[widget.nodeId];
    if (node != null) {
      localOffset = node.position;
    }

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
    if (oldWidget.nodeId != widget.nodeId) {
      final node = ref.read(nodeProvider)[widget.nodeId];
      if (node != null) {
        localOffset = node.position;
      }
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
    final node = ref.watch(
      nodeProvider.select((nodes) => nodes[widget.nodeId]),
    );

    final bool isDarkMode = ref.watch(themeProvider) == ThemeMode.dark;

    if (node == null) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: node.position.dx - node.size / 2,
      top: node.position.dy - node.size / 2,
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
                      .updateNode(node.copyWith(position: localOffset));
                },
        onTap: widget.isMenuActive ? null : widget.onTap,
        child: AnimatedBuilder(
          animation: _curvedAnimation,
          builder: (context, child) {
            final scale = 1.0 + (_curvedAnimation.value * 0.1);
            return Transform.scale(
              scale: scale,
              child: Container(
                width: node.size,
                height: node.size,
                decoration: BoxDecoration(
                  color: node.color,
                  shape: node.shape,
                  borderRadius:
                      node.shape == BoxShape.rectangle
                          ? BorderRadius.circular(6)
                          : null,
                  border:
                      isDarkMode
                          ? widget.isConnecting
                              ? Border.all(color: Colors.white, width: 2)
                              : null
                          : Border.all(
                            color: Colors.black,
                            width: widget.isConnecting ? 2 : 1,
                          ),
                ),
                alignment: Alignment.center,
                child: Text(
                  node.text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize:
                        node.size > 60
                            ? 16
                            : node.size > 40
                            ? 10
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
