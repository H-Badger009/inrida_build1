import 'package:flutter/material.dart';

class ProfileAboutSection extends StatelessWidget {
  final TextEditingController aboutController;
  final bool isEditing;
  final Function(String) onAboutChanged;

  const ProfileAboutSection({
    super.key,
    required this.aboutController,
    required this.isEditing,
    required this.onAboutChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const Text(
          'About',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        isEditing
            ? TextField(
                controller: aboutController,
                onChanged: onAboutChanged,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: "I'm a professional doctor with...",
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                ),
                textDirection: TextDirection.ltr, // Force LTR
              )
            : Text(
                aboutController.text.isEmpty ? "I'm a professional doctor with..." : aboutController.text,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
      ],
    );
  }
}