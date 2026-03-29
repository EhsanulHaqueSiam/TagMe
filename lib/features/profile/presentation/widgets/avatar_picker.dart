import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tagme/core/constants/app_colors.dart';

/// Circular avatar with a camera overlay that opens image_picker.
class AvatarPicker extends StatelessWidget {
  const AvatarPicker({
    required this.onPhotoPicked,
    super.key,
    this.currentPhotoPath,
  });

  /// Path to the currently selected photo file, if any.
  final String? currentPhotoPath;

  /// Called when the user picks a photo from camera or gallery.
  final ValueChanged<File?> onPhotoPicked;

  Future<void> _pickImage(BuildContext context) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.close),
              title: const Text('Cancel'),
              onTap: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    final picker = ImagePicker();
    final xFile = await picker.pickImage(
      source: source,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );

    if (xFile != null) {
      onPhotoPicked(File(xFile.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _pickImage(context),
      child: SizedBox(
        width: 96,
        height: 96,
        child: Stack(
          children: [
            // Avatar circle
            CircleAvatar(
              radius: 48,
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              backgroundImage: currentPhotoPath != null
                  ? FileImage(File(currentPhotoPath!))
                  : null,
              child: currentPhotoPath == null
                  ? Icon(
                      Icons.person,
                      size: 48,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    )
                  : null,
            ),
            // Camera icon overlay
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera_alt,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
