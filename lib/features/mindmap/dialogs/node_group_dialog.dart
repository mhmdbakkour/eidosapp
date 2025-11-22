import 'package:csci410project/features/mindmap/models/node_group_model.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class NodeGroupDialog extends StatefulWidget {
  final String dialogText;
  final NodeGroup? nodeGroup;

  const NodeGroupDialog({super.key, required this.dialogText, this.nodeGroup});

  @override
  State<NodeGroupDialog> createState() => _NodeGroupDialogState();
}

class _NodeGroupDialogState extends State<NodeGroupDialog> {
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
      text: widget.nodeGroup?.size.width.toString() ?? '100',
    );
    _nodeGroupHeightController = TextEditingController(
      text: widget.nodeGroup?.size.height.toString() ?? '100',
    );
    _selectedColor = widget.nodeGroup?.color.toString() ?? 'Blue';
    print(_selectedColor.toString());
  }

  @override
  void dispose() {
    _nodeGroupTitleController.dispose();
    super.dispose();
  }

  void _onSave() {
    final Color savedColor;

    switch (_selectedColor) {
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
      case "Yellow":
        savedColor = Colors.yellow.shade700;
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
    return AlertDialog(
      title: Text(widget.dialogText),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
                    border: OutlineInputBorder(),
                  ),
                  controller: _nodeGroupWidthController,
                  maxLength: 4,
                ),
              ),
              const SizedBox(width: 2),
              Flexible(
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Height',
                    border: OutlineInputBorder(),
                  ),
                  controller: _nodeGroupHeightController,
                  maxLength: 4,
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
                value: 'Yellow',
                label: "Yellow",
                leadingIcon: Icon(
                  Icons.square_rounded,
                  color: Colors.yellow.shade700,
                ),
              ),
              DropdownMenuEntry(
                value: 'Pink',
                label: "Pink",
                leadingIcon: Icon(Icons.square_rounded, color: Colors.pink),
              ),
            ],
          ),
        ],
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
