import 'package:flutter/material.dart';

class ProfileAboutSection extends StatelessWidget {
  final String about;
  final bool isEditing;
  final Function(String) onAboutChanged;

  const ProfileAboutSection({
    super.key,
    required this.about,
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
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        isEditing
            ? TextField(
                controller: TextEditingController(text: about),
                onChanged: onAboutChanged,
                maxLines: 3,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Tell us about yourself...',
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 12,
                  ),
                ),
              )
            : Text(
                about.isEmpty
                    ? 'No information provided.'
                    : about,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
      ],
    );
  }
}