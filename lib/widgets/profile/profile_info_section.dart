import 'package:flutter/material.dart';

class ProfileInfoSection extends StatelessWidget {
  final String email;
  final String phone;
  final String location;
  final bool isEditing;
  final Function(String) onEmailChanged;
  final Function(String) onPhoneChanged;
  final Function(String) onLocationChanged;

  const ProfileInfoSection({
    super.key,
    required this.email,
    required this.phone,
    required this.location,
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
          value: email,
          isEditing: isEditing,
          onChanged: onEmailChanged,
          placeholder: 'user@inrida.com',
        ),
        const SizedBox(height: 16),
        _buildInfoRow(
          label: 'Phone',
          value: phone,
          isEditing: isEditing,
          onChanged: onPhoneChanged,
          placeholder: '+250 12 345 6789',
        ),
        const SizedBox(height: 16),
        _buildInfoRow(
          label: 'Location',
          value: location,
          isEditing: isEditing,
          onChanged: onLocationChanged,
          placeholder: 'City, Country',
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
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
                      controller: TextEditingController(text: value.isEmpty ? null : value),
                      onChanged: onChanged,
                      decoration: InputDecoration(
                        hintText: value.isEmpty ? placeholder : null,
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      ),
                    )
                  : Text(
                      value.isEmpty ? placeholder : value,
                      style: TextStyle(
                        fontSize: 16,
                        color: value.isEmpty ? Colors.grey : Colors.black,
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