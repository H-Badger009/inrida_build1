import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileHeader extends StatelessWidget {
  final String name;
  final String? profileImage;
  final bool isEditing;
  final Function(String) onNameChanged;
  final Function(XFile?) onImageChanged;

  const ProfileHeader({
    super.key,
    required this.name,
    required this.profileImage,
    required this.isEditing,
    required this.onNameChanged,
    required this.onImageChanged,
  });

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    onImageChanged(image);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            GestureDetector(
              onTap: isEditing ? _pickImage : null,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[200],
                backgroundImage: profileImage != null && profileImage!.isNotEmpty
                    ? NetworkImage(profileImage!)
                    : null,
                child: profileImage == null || profileImage!.isEmpty
                    ? const Icon(Icons.person, size: 50, color: Colors.grey)
                    : null,
              ),
            ),
            if (isEditing)
              Positioned(
                bottom: 5,
                right: 5,
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey, width: 1),
                    ),
                    child: const Icon(Icons.edit, size: 16, color: Colors.grey),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        isEditing
            ? TextField(
                decoration: const InputDecoration(
                  hintText: 'Enter your name',
                  border: OutlineInputBorder(),
                ),
                textAlign: TextAlign.center,
                controller: TextEditingController(text: name),
                onChanged: onNameChanged,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              )
            : Text(
                name.isEmpty ? 'User' : name,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
      ],
    );
  }
}