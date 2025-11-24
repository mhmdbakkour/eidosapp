import 'package:csci410project/features/mindmap/models/node_group_model.dart';
import 'package:csci410project/features/mindmap/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

class NodeGroupDialog extends ConsumerStatefulWidget {
  final String dialogText;
  final NodeGroup? nodeGroup;

  const NodeGroupDialog({super.key, required this.dialogText, this.nodeGroup});

  @override
  ConsumerState<NodeGroupDialog> createState() => _NodeGroupDialogState();
}

class _NodeGroupDialogState extends ConsumerState<NodeGroupDialog> {
  late TextEditingController _nodeGroupTitleController;
  late TextEditingController _nodeGroupWidthController;
  late TextEditingController _nodeGroupHeightController;
  late String _selectedColor;

  @override
  void initState() {
    super.initState();
    _nodeGroupTitleController = TextEditingController(
      text: widget.nodeGroup?.title ?? '',
    );
    _nodeGroupWidthController = TextEditingController(
      text: widget.nodeGroup?.size.width.toInt().toString() ?? '300',
    );
    _nodeGroupHeightController = TextEditingController(
      text: widget.nodeGroup?.size.height.toInt().toString() ?? '300',
    );

    if (widget.nodeGroup != null) {
      if (widget.nodeGroup!.color == Colors.black ||
          widget.nodeGroup!.color == Colors.white) {
        _selectedColor = "Contrast";
      } else if (widget.nodeGroup!.color == Colors.red) {
        _selectedColor = "Red";
      } else if (widget.nodeGroup!.color == Colors.orange) {
        _selectedColor = "Orange";
      } else if (widget.nodeGroup!.color == Colors.green) {
        _selectedColor = "Green";
      } else if (widget.nodeGroup!.color == Colors.purple) {
        _selectedColor = "Purple";
      } else if (widget.nodeGroup!.color == Colors.pink) {
        _selectedColor = "Pink";
      } else {
        _selectedColor = "Blue";
      }
    } else {
      _selectedColor = "Blue";
    }
  }

  @override
  void dispose() {
    _nodeGroupTitleController.dispose();
    super.dispose();
  }

  void _onSave() {
    final Color savedColor;

    final bool isDarkMode = ref.read(themeProvider) == ThemeMode.dark;

    switch (_selectedColor) {
      case "Contrast":
        savedColor = isDarkMode ? Colors.white : Colors.black;
        break;
      case "Red":
        savedColor = Colors.red;
        break;
      case "Orange":
        savedColor = Colors.orange;
        break;
      case "Green":
        savedColor = Colors.green;
        break;
      case "Purple":
        savedColor = Colors.purple;
        break;
      case "Pink":
        savedColor = Colors.pink;
        break;
      default:
        savedColor = Colors.blue;
    }

    final newNodeGroup = NodeGroup(
      id: widget.nodeGroup?.id ?? Uuid().v4(),
      title: _nodeGroupTitleController.text,
      position: widget.nodeGroup?.position ?? Offset.zero,
      size: Size(
        double.tryParse(_nodeGroupWidthController.text)!,
        double.tryParse(_nodeGroupHeightController.text)!,
      ),
      color: savedColor,
    );
    Navigator.pop(context, newNodeGroup);
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = ref.watch(themeProvider) == ThemeMode.dark;

    return AlertDialog(
      title: Text(widget.dialogText),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 5),
            TextFormField(
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              controller: _nodeGroupTitleController,
              maxLength: 24,
            ),
            Row(
              children: [
                Flexible(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Width',
                      suffixText: "px",
                      border: OutlineInputBorder(),
                    ),
                    controller: _nodeGroupWidthController,
                    maxLength: 4,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 2),
                Flexible(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Height',
                      suffixText: "px",
                      border: OutlineInputBorder(),
                    ),
                    controller: _nodeGroupHeightController,
                    maxLength: 4,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            DropdownMenu(
              label: const Text("Group color"),
              initialSelection: _selectedColor,
              onSelected: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedColor = newValue;
                  });
                }
              },
              dropdownMenuEntries: [
                DropdownMenuEntry(
                  value: 'Blue',
                  label: "Blue",
                  leadingIcon: Icon(Icons.square_rounded, color: Colors.blue),
                ),
                DropdownMenuEntry(
                  value: 'Red',
                  label: "Red",
                  leadingIcon: Icon(Icons.square_rounded, color: Colors.red),
                ),
                DropdownMenuEntry(
                  value: 'Orange',
                  label: "Orange",
                  leadingIcon: Icon(Icons.square_rounded, color: Colors.orange),
                ),
                DropdownMenuEntry(
                  value: 'Green',
                  label: "Green",
                  leadingIcon: Icon(Icons.square_rounded, color: Colors.green),
                ),
                DropdownMenuEntry(
                  value: 'Purple',
                  label: "Purple",
                  leadingIcon: Icon(Icons.square_rounded, color: Colors.purple),
                ),
                DropdownMenuEntry(
                  value: 'Pink',
                  label: "Pink",
                  leadingIcon: Icon(Icons.square_rounded, color: Colors.pink),
                ),
                DropdownMenuEntry(
                  value: 'Contrast',
                  label: "Contrast",
                  leadingIcon: Icon(
                    Icons.square_rounded,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        TextButton(onPressed: _onSave, child: const Text("Save")),
      ],
    );
  }
}
