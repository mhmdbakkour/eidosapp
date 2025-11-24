import 'package:flutter/material.dart';

import '../models/node_model.dart';

import 'package:uuid/uuid.dart';

class NodeDialog extends StatefulWidget {
  final String dialogText;
  final Node? node;

  const NodeDialog({super.key, required this.dialogText, this.node});

  @override
  State<NodeDialog> createState() => _NodeDialogState();
}

class _NodeDialogState extends State<NodeDialog> {
  late TextEditingController _nodeTextController;
  late String _selectedSize;
  late String _selectedShape;
  late String _selectedColor;

  @override
  void initState() {
    super.initState();
    _nodeTextController = TextEditingController(text: widget.node?.text ?? '');
    _selectedSize = widget.node?.size.toInt().toString() ?? '60';
    _selectedShape =
        widget.node?.shape == BoxShape.rectangle ? "Square" : "Circle";

    if (widget.node != null) {
      if (widget.node!.color == Colors.red) {
        _selectedColor = "Red";
      } else if (widget.node!.color == Colors.orange) {
        _selectedColor = "Orange";
      } else if (widget.node!.color == Colors.green) {
        _selectedColor = "Green";
      } else if (widget.node!.color == Colors.purple) {
        _selectedColor = "Purple";
      } else if (widget.node!.color == Colors.pink) {
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
    _nodeTextController.dispose();
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
      case "Pink":
        savedColor = Colors.pink;
        break;
      default:
        savedColor = Colors.blue;
    }

    final newNode = Node(
      id: widget.node?.id ?? Uuid().v4(),
      text: _nodeTextController.text,
      position: widget.node?.position ?? Offset.zero,
      size: double.tryParse(_selectedSize) ?? 60.0,
      shape: _selectedShape == "Square" ? BoxShape.rectangle : BoxShape.circle,
      color: savedColor,
    );
    Navigator.pop(context, newNode);
  }

  @override
  Widget build(BuildContext context) {
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
                labelText: 'Text',
                border: OutlineInputBorder(),
              ),
              controller: _nodeTextController,
              maxLength: 8,
            ),
            DropdownMenu(
              label: const Text("Node size"),
              initialSelection: _selectedSize,
              onSelected: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedSize = newValue;
                  });
                }
              },
              dropdownMenuEntries: const [
                DropdownMenuEntry(value: '40', label: "Small"),
                DropdownMenuEntry(value: '60', label: "Medium"),
                DropdownMenuEntry(value: '80', label: "Large"),
              ],
            ),
            SizedBox(height: 10),
            DropdownMenu(
              label: const Text("Node shape"),
              initialSelection: _selectedShape,
              onSelected: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedShape = newValue;
                  });
                }
              },
              dropdownMenuEntries: const [
                DropdownMenuEntry(
                  value: 'Square',
                  label: "Square",
                  leadingIcon: Icon(
                    Icons.square_rounded,
                    color: Colors.black12,
                  ),
                ),
                DropdownMenuEntry(
                  value: 'Circle',
                  label: "Circle",
                  leadingIcon: Icon(Icons.circle, color: Colors.black12),
                ),
              ],
            ),
            SizedBox(height: 10),
            DropdownMenu(
              label: const Text("Node color"),
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
                  leadingIcon: Icon(
                    _selectedShape == "Square"
                        ? Icons.square_rounded
                        : Icons.circle,
                    color: Colors.blue,
                  ),
                ),
                DropdownMenuEntry(
                  value: 'Red',
                  label: "Red",
                  leadingIcon: Icon(
                    _selectedShape == "Square"
                        ? Icons.square_rounded
                        : Icons.circle,
                    color: Colors.red,
                  ),
                ),
                DropdownMenuEntry(
                  value: 'Orange',
                  label: "Orange",
                  leadingIcon: Icon(
                    _selectedShape == "Square"
                        ? Icons.square_rounded
                        : Icons.circle,
                    color: Colors.orange,
                  ),
                ),
                DropdownMenuEntry(
                  value: 'Green',
                  label: "Green",
                  leadingIcon: Icon(
                    _selectedShape == "Square"
                        ? Icons.square_rounded
                        : Icons.circle,
                    color: Colors.green,
                  ),
                ),
                DropdownMenuEntry(
                  value: 'Purple',
                  label: "Purple",
                  leadingIcon: Icon(
                    _selectedShape == "Square"
                        ? Icons.square_rounded
                        : Icons.circle,
                    color: Colors.purple,
                  ),
                ),
                DropdownMenuEntry(
                  value: 'Pink',
                  label: "Pink",
                  leadingIcon: Icon(
                    _selectedShape == "Square"
                        ? Icons.square_rounded
                        : Icons.circle,
                    color: Colors.pink,
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
