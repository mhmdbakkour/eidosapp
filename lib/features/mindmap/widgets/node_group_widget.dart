import 'package:csci410project/features/mindmap/providers/node_group_provider.dart';
import 'package:csci410project/features/mindmap/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/node_group_model.dart';

class NodeGroupWidget extends ConsumerStatefulWidget {
  final String nodeGroupId;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const NodeGroupWidget({
    super.key,
    required this.nodeGroupId,
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
    final nodeGroup = ref
        .read(nodeGroupProvider)
        .values
        .firstWhere((g) => g.id == widget.nodeGroupId);
    localOffset = nodeGroup.position;
  }

  @override
  Widget build(BuildContext context) {
    final nodeGroup = ref
        .watch(nodeGroupProvider)
        .values
        .firstWhere(
          (g) => g.id == widget.nodeGroupId,
          orElse: () => NodeGroup.empty(),
        );

    final bool isDarkMode = ref.watch(themeProvider) == ThemeMode.dark;

    if (nodeGroup.id.isEmpty) return Container();

    return Positioned(
      left: nodeGroup.position.dx - nodeGroup.size.width / 2,
      top: nodeGroup.position.dy - nodeGroup.size.height / 2,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: nodeGroup.size.width,
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  localOffset += details.delta;
                });
                ref
                    .read(nodeGroupProvider.notifier)
                    .updateNodeGroup(nodeGroup.copyWith(position: localOffset));
              },
              child: Container(
                decoration: BoxDecoration(
                  color:
                      isDarkMode
                          ? nodeGroup.color == Colors.black
                              ? Colors.white.withAlpha(30)
                              : nodeGroup.color.withAlpha(30)
                          : nodeGroup.color == Colors.white
                          ? Colors.black.withAlpha(60)
                          : Color.lerp(
                            nodeGroup.color.withAlpha(60),
                            Colors.black,
                            0.25,
                          )!,
                  border: Border.all(
                    color:
                        isDarkMode
                            ? nodeGroup.color == Colors.black
                                ? Colors.white
                                : nodeGroup.color
                            : nodeGroup.color == Colors.white
                            ? Colors.black
                            : Color.lerp(nodeGroup.color, Colors.black, 0.25)!,
                  ),
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
                                nodeGroup.copyWith(position: localOffset),
                              );
                        },
                        child: Center(
                          child: Text(
                            nodeGroup.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color:
                                  isDarkMode
                                      ? nodeGroup.color == Colors.black
                                          ? Colors.white
                                          : nodeGroup.color
                                      : nodeGroup.color == Colors.white
                                      ? Colors.black
                                      : Color.lerp(
                                        nodeGroup.color,
                                        Colors.black,
                                        0.25,
                                      )!,
                            ),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.edit,
                        color:
                            isDarkMode
                                ? nodeGroup.color == Colors.black
                                    ? Colors.white
                                    : nodeGroup.color
                                : nodeGroup.color == Colors.white
                                ? Colors.black
                                : Color.lerp(
                                  nodeGroup.color,
                                  Colors.black,
                                  0.25,
                                )!,
                      ),
                      onPressed: widget.onEdit,
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color:
                            isDarkMode
                                ? nodeGroup.color == Colors.black
                                    ? Colors.white
                                    : nodeGroup.color
                                : nodeGroup.color == Colors.white
                                ? Colors.black
                                : Color.lerp(
                                  nodeGroup.color,
                                  Colors.black,
                                  0.25,
                                )!,
                      ),
                      onPressed: widget.onDelete,
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 4),
          Container(
            width: nodeGroup.size.width,
            height: nodeGroup.size.height,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color:
                  isDarkMode
                      ? nodeGroup.color == Colors.black
                          ? Colors.white.withAlpha(30)
                          : nodeGroup.color.withAlpha(30)
                      : nodeGroup.color == Colors.white
                      ? Colors.black.withAlpha(60)
                      : Color.lerp(
                        nodeGroup.color.withAlpha(60),
                        Colors.black,
                        0.25,
                      )!,
              border: Border.all(
                color:
                    isDarkMode
                        ? nodeGroup.color == Colors.black
                            ? Colors.white
                            : nodeGroup.color
                        : nodeGroup.color == Colors.white
                        ? Colors.black
                        : Color.lerp(nodeGroup.color, Colors.black, 0.25)!,
                width: 2.0,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ],
      ),
    );
  }
}
