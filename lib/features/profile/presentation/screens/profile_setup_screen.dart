import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tagme/core/constants/app_colors.dart';
import 'package:tagme/core/constants/app_spacing.dart';
import 'package:tagme/features/profile/data/models/student.dart';
import 'package:tagme/features/profile/presentation/widgets/avatar_picker.dart';
import 'package:tagme/features/profile/presentation/widgets/gender_selector.dart';
import 'package:tagme/features/profile/presentation/widgets/university_dropdown.dart';
import 'package:tagme/features/profile/providers/profile_provider.dart';

/// Screen for creating a new student profile.
class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() =>
      _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  File? _photoFile;
  String _university = '';
  String? _gender;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool get _isFormValid =>
      _nameController.text.trim().length >= 2 &&
      _university.isNotEmpty &&
      _gender != null;

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate() || !_isFormValid) return;

    setState(() => _isSaving = true);

    final student = Student(
      name: _nameController.text.trim(),
      university: _university,
      gender: _gender!,
      photoUrl: _photoFile?.path,
    );

    await ref
        .read(profileProvider.notifier)
        .saveProfile(student);

    if (mounted) {
      context.go('/map');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Up Your Profile'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.lg),

              // Avatar picker (centered)
              Center(
                child: AvatarPicker(
                  currentPhotoPath: _photoFile?.path,
                  onPhotoPicked: (file) {
                    setState(() => _photoFile = file);
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Full Name
              Text(
                'Full Name',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: AppColors.onSurfaceDim,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: 'Enter your full name',
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().length < 2) {
                    return 'Enter your name to continue';
                  }
                  return null;
                },
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: AppSpacing.lg),

              // University
              Text(
                'University',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: AppColors.onSurfaceDim,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              UniversityDropdown(
                selectedUniversity:
                    _university.isNotEmpty ? _university : null,
                onSelected: (value) {
                  setState(() => _university = value);
                },
              ),
              const SizedBox(height: AppSpacing.lg),

              // Gender
              Text(
                'Gender',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: AppColors.onSurfaceDim,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              GenderSelector(
                selectedGender: _gender,
                onSelected: (value) {
                  setState(() => _gender = value);
                },
              ),
              const SizedBox(height: AppSpacing.xl),

              // Save button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isFormValid && !_isSaving
                      ? _saveProfile
                      : null,
                  style: ElevatedButton.styleFrom(
                    disabledBackgroundColor:
                        AppColors.accent.withValues(alpha: 0.38),
                    disabledForegroundColor:
                        Colors.white.withValues(alpha: 0.38),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Save Profile'),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}
