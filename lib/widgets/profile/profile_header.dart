import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileHeader extends StatelessWidget {
  final String name;
  final String? profileImage; // URL from Firestore
  final XFile? newImage; // Local image file before upload
  final bool isEditing;
  final TextEditingController nameController;
  final Function(XFile?) onImageChanged;

  const ProfileHeader({
    super.key,
    required this.name,
    required this.profileImage,
    required this.newImage,
    required this.isEditing,
    required this.nameController,
    required this.onImageChanged,
  });

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      onImageChanged(image); // Notify parent to update _newImage
    }
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
                backgroundImage: newImage != null
                    ? FileImage(File(newImage!.path)) // Show local image if picked
                    : (profileImage != null && profileImage!.isNotEmpty
                        ? NetworkImage(profileImage!) // Show Firestore image if available
                        : null),
                child: (newImage == null && (profileImage == null || profileImage!.isEmpty))
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
                controller: nameController,
                onChanged: (value) {}, // Handled by parent
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textDirection: TextDirection.ltr, // Force LTR
              )
            : Text(
                name.isEmpty ? 'User' : name,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
      ],
    );
  }
}