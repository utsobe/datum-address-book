import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../modules/contact_form/controllers/contact_form_controller.dart';
import '../language/localization_service.dart';

class AvatarPicker extends StatelessWidget {
  final String? avatarPath;
  final Function(String) onImageSelected;
  final VoidCallback onImageRemoved;

  const AvatarPicker({
    super.key,
    this.avatarPath,
    required this.onImageSelected,
    required this.onImageRemoved,
  });

  @override
  Widget build(BuildContext context) {
    const size = 120.0;

    return GestureDetector(
      onTap: () => _showImagePicker(context),
      child: Stack(
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.1),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: _buildAvatarContent(context, size),
          ),

          // Edit button
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  width: 3,
                ),
              ),
              child: IconButton(
                onPressed: () => _showImagePicker(context),
                icon: const Icon(Icons.camera_alt),
                color: Colors.white,
                iconSize: 20,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                padding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarContent(BuildContext context, double size) {
    if (avatarPath != null && avatarPath!.isNotEmpty) {
      final file = File(avatarPath!);
      if (file.existsSync()) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(size / 2),
          child: Image.file(file, width: size, height: size, fit: BoxFit.cover),
        );
      }
    }

    // Default avatar placeholder
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_add,
            size: 40,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
          ),
          const SizedBox(height: 8),
          Text(
            'Add Photo',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showImagePicker(BuildContext context) {
    final localization = LocalizationService.to;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Change Profile Photo',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPickerOption(
                  context,
                  icon: Icons.camera_alt,
                  label: localization.takePhoto,
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(fromCamera: true);
                  },
                ),

                _buildPickerOption(
                  context,
                  icon: Icons.photo_library,
                  label: localization.choosePhoto,
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(fromCamera: false);
                  },
                ),

                if (avatarPath != null && avatarPath!.isNotEmpty)
                  _buildPickerOption(
                    context,
                    icon: Icons.delete,
                    label: localization.removePhoto,
                    onTap: () {
                      Navigator.pop(context);
                      onImageRemoved();
                    },
                    isDestructive: true,
                  ),
              ],
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPickerOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isDestructive
                  ? Colors.red.withValues(alpha: 0.1)
                  : Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isDestructive
                  ? Colors.red
                  : Theme.of(context).colorScheme.primary,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
              color: isDestructive ? Colors.red : null,
            ),
          ),
        ],
      ),
    );
  }

  void _pickImage({required bool fromCamera}) {
    final controller = Get.find<ContactFormController>();
    controller.pickImage(fromCamera: fromCamera);
  }
}
