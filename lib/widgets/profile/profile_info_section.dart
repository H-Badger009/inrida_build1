import 'package:flutter/material.dart';

class ProfileInfoSection extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController locationController;
  final bool isEditing;
  final Function(String) onEmailChanged;
  final Function(String) onPhoneChanged;
  final Function(String) onLocationChanged;

  const ProfileInfoSection({
    super.key,
    required this.emailController,
    required this.phoneController,
    required this.locationController,
    required this.isEditing,
    required this.onEmailChanged,
    required this.onPhoneChanged,
    required this.onLocationChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Personal Information',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildInfoRow(
          label: 'Email',
          controller: emailController,
          isEditing: isEditing,
          onChanged: onEmailChanged,
          placeholder: 'user@inrida.com',
        ),
        const SizedBox(height: 16),
        _buildInfoRow(
          label: 'Phone',
          controller: phoneController,
          isEditing: isEditing,
          onChanged: onPhoneChanged,
          placeholder: '+250 12 345 6789',
        ),
        const SizedBox(height: 16),
        _buildInfoRow(
          label: 'Location',
          controller: locationController,
          isEditing: isEditing,
          onChanged: onLocationChanged,
          placeholder: 'City, Country',
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required String label,
    required TextEditingController controller,
    required bool isEditing,
    required Function(String) onChanged,
    required String placeholder,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              isEditing
                  ? TextField(
                      controller: controller,
                      onChanged: onChanged,
                      decoration: InputDecoration(
                        hintText: controller.text.isEmpty ? placeholder : null,
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      ),
                      textDirection: TextDirection.ltr, // Force LTR
                    )
                  : Text(
                      controller.text.isEmpty ? placeholder : controller.text,
                      style: TextStyle(
                        fontSize: 16,
                        color: controller.text.isEmpty ? Colors.grey : Colors.black,
                      ),
                    ),
            ],
          ),
        ),
        if (!isEditing)
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      ],
    );
  }
}