import 'package:flutter/material.dart';

class ProfileInfoSection extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController streetAddressController;
  final TextEditingController townController;
  final TextEditingController cityController;
  final TextEditingController countryController;
  final TextEditingController postalCodeController;
  final bool isEditing;
  final Function(String) onEmailChanged;
  final Function(String) onPhoneChanged;
  final Function(String) onStreetAddressChanged;
  final Function(String) onTownChanged;
  final Function(String) onCityChanged;
  final Function(String) onCountryChanged;
  final Function(String) onPostalCodeChanged;

  const ProfileInfoSection({
    super.key,
    required this.emailController,
    required this.phoneController,
    required this.streetAddressController,
    required this.townController,
    required this.cityController,
    required this.countryController,
    required this.postalCodeController,
    required this.isEditing,
    required this.onEmailChanged,
    required this.onPhoneChanged,
    required this.onStreetAddressChanged,
    required this.onTownChanged,
    required this.onCityChanged,
    required this.onCountryChanged,
    required this.onPostalCodeChanged,
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
          label: 'Street Address',
          controller: streetAddressController,
          isEditing: isEditing,
          onChanged: onStreetAddressChanged,
          placeholder: '123 Main St',
        ),
        const SizedBox(height: 16),
        _buildInfoRow(
          label: 'Town',
          controller: townController,
          isEditing: isEditing,
          onChanged: onTownChanged,
          placeholder: 'Springfield',
        ),
        const SizedBox(height: 16),
        _buildInfoRow(
          label: 'City',
          controller: cityController,
          isEditing: isEditing,
          onChanged: onCityChanged,
          placeholder: 'Metropolis',
        ),
        const SizedBox(height: 16),
        _buildInfoRow(
          label: 'Country',
          controller: countryController,
          isEditing: isEditing,
          onChanged: onCountryChanged,
          placeholder: 'USA',
        ),
        const SizedBox(height: 16),
        _buildInfoRow(
          label: 'Postal Code',
          controller: postalCodeController,
          isEditing: isEditing,
          onChanged: onPostalCodeChanged,
          placeholder: '12345',
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
      ],
    );
  }
}