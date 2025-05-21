import 'package:flutter/material.dart';

class EditableField extends StatefulWidget {
  final String label;
  final String initialValue;
  final int maxLines;
  final Function(String) onSave;

  const EditableField({
    super.key,
    required this.label,
    required this.initialValue,
    required this.onSave,
    this.maxLines = 1,
  });

  @override
  State<EditableField> createState() => _EditableFieldState();
}

class _EditableFieldState extends State<EditableField> {
  late TextEditingController controller;
  bool isEditing = false;

  @override
  void initState() {
    controller = TextEditingController(text: widget.initialValue);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(widget.label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            IconButton(
              icon: Icon(isEditing ? Icons.check : Icons.edit),
              onPressed: () {
                if (isEditing) {
                  widget.onSave(controller.text.trim());
                }
                setState(() => isEditing = !isEditing);
              },
            )
          ],
        ),
        TextField(
          controller: controller,
          maxLines: widget.maxLines,
          enabled: isEditing,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
