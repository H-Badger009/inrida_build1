import 'package:flutter/material.dart';

class ProfileSettingsSection extends StatelessWidget {
  final bool pushNotifications;
  final bool newsletter;
  final bool twoFactorAuth;
  final bool isEditing;
  final Function(bool) onPushNotificationsChanged;
  final Function(bool) onNewsletterChanged;
  final Function(bool) onTwoFactorAuthChanged;

  const ProfileSettingsSection({
    super.key,
    required this.pushNotifications,
    required this.newsletter,
    required this.twoFactorAuth,
    required this.isEditing,
    required this.onPushNotificationsChanged,
    required this.onNewsletterChanged,
    required this.onTwoFactorAuthChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const Text(
          'Settings',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildSwitchRow(
          title: 'Push Notifications',
          subtitle: 'Get notified about new messages',
          value: pushNotifications,
          onChanged: onPushNotificationsChanged,
          isEditing: isEditing,
        ),
        const SizedBox(height: 16),
        _buildSwitchRow(
          title: 'Newsletter',
          subtitle: 'Receive weekly updates',
          value: newsletter,
          onChanged: onNewsletterChanged,
          isEditing: isEditing,
        ),
        const SizedBox(height: 16),
        _buildSwitchRow(
          title: 'Two-Factor Authentication',
          subtitle: 'Enhanced account security',
          value: twoFactorAuth,
          onChanged: onTwoFactorAuthChanged,
          isEditing: isEditing,
        ),
      ],
    );
  }

  Widget _buildSwitchRow({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    required bool isEditing,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: isEditing ? onChanged : null,
          activeColor: Colors.teal,
        ),
      ],
    );
  }
}