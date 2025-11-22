import 'package:csci410project/features/mindmap/providers/node_group_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/node_group_model.dart';

class NodeGroupWidget extends ConsumerStatefulWidget {
  final NodeGroup nodeGroup;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const NodeGroupWidget({
    super.key,
    required this.nodeGroup,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  ConsumerState<NodeGroupWidget> createState() => _NodeGroupWidgetState();
}

class _NodeGroupWidgetState extends ConsumerState<NodeGroupWidget> {
  Offset localOffset = Offset.zero;

  @override
  void initState() {
    super.initState();
    localOffset = widget.nodeGroup.position;
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.nodeGroup.position.dx - widget.nodeGroup.size.width / 2,
      top: widget.nodeGroup.position.dy - widget.nodeGroup.size.height / 2,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: widget.nodeGroup.size.width,
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  localOffset += details.delta;
                });
                ref
                    .read(nodeGroupProvider.notifier)
                    .updateNodeGroup(
                      widget.nodeGroup.copyWith(position: localOffset),
                    );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: widget.nodeGroup.color.withAlpha(30),
                  border: Border.all(color: widget.nodeGroup.color),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Flexible(
                      child: GestureDetector(
                        onPanUpdate: (details) {
                          setState(() {
                            localOffset += details.delta;
                          });
                          ref
                              .read(nodeGroupProvider.notifier)
                              .updateNodeGroup(
                                widget.nodeGroup.copyWith(
                                  position: localOffset,
                                ),
                              );
                        },
                        child: Center(
                          child: Text(
                            widget.nodeGroup.title ?? "Group",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: widget.nodeGroup.color,
                            ),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.edit, color: widget.nodeGroup.color),
                      onPressed: widget.onEdit,
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: widget.nodeGroup.color),
                      onPressed: widget.onDelete,
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 4),
          Container(
            width: widget.nodeGroup.size.width,
            height: widget.nodeGroup.size.height,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: widget.nodeGroup.color.withAlpha(30),
              border: Border.all(color: widget.nodeGroup.color, width: 2.0),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ],
      ),
    );
  }
}
