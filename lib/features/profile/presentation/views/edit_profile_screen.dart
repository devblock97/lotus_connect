import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lotus_connect/features/profile/application/profile_providers.dart';
import 'package:lotus_connect/features/profile/domain/entities/update_profile_params.dart';
import 'package:lotus_connect/features/profile/domain/entities/user_profile.dart';
import 'package:lotus_connect/l10n/app_localizations.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({
    this.initialProfile,
    super.key,
  });

  final UserProfile? initialProfile;

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullNameController;
  late final TextEditingController _bioController;
  late final TextEditingController _locationController;
  late final TextEditingController _websiteController;

  @override
  void initState() {
    super.initState();
    final profile =
        widget.initialProfile ?? ref.read(myProfileNotifierProvider).profile;
    _fullNameController = TextEditingController(text: profile?.fullName ?? '');
    _bioController = TextEditingController(text: profile?.bio ?? '');
    _locationController = TextEditingController(text: profile?.location ?? '');
    _websiteController = TextEditingController(text: profile?.website ?? '');
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadAvatar() async {
    final source = await _showImageSourceSheet();
    if (source == null) return;

    final picker = ImagePicker();
    try {
      final image = await picker.pickImage(
        source: source,
        imageQuality: 88,
        maxWidth: 1080,
      );
      if (image == null || !mounted) return;

      final success = await ref
          .read(myProfileNotifierProvider.notifier)
          .uploadAvatar(image.path);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Profile picture updated!'
                : 'Failed to upload profile picture.',
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    } on Object catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }

  Future<void> _pickAndUploadCover() async {
    final source = await _showImageSourceSheet();
    if (source == null) return;

    final picker = ImagePicker();
    try {
      final image = await picker.pickImage(
        source: source,
        imageQuality: 88,
        maxWidth: 1920,
      );
      if (image == null || !mounted) return;

      final success = await ref
          .read(myProfileNotifierProvider.notifier)
          .uploadCover(image.path);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'Cover photo updated!' : 'Failed to upload cover photo.',
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    } on Object catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }

  Future<ImageSource?> _showImageSourceSheet() {
    final loc = AppLocalizations.of(context);
    return showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: Text(loc?.modeGallery ?? 'Choose from Gallery'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded),
              title: Text(loc?.modeCamera ?? 'Take a Photo'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final notifier = ref.read(myProfileNotifierProvider.notifier);
    final success = await notifier.updateProfile(
      UpdateProfileParams(
        fullName: _fullNameController.text.trim(),
        bio: _bioController.text.trim(),
        location: _locationController.text.trim(),
        website: _websiteController.text.trim(),
      ),
    );

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } else {
      final err = ref.read(myProfileNotifierProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err ?? 'Failed to update profile'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final loc = AppLocalizations.of(context);
    final state = ref.watch(myProfileNotifierProvider);
    final profile = state.profile ?? widget.initialProfile;

    final hasAvatar =
        profile?.avatarUrl != null && profile!.avatarUrl!.isNotEmpty;
    final hasCover = profile?.coverUrl != null && profile!.coverUrl!.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          loc?.editProfile ?? 'Edit Profile',
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: state.isUpdatingProfile ? null : _saveProfile,
            child: state.isUpdatingProfile
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    loc?.save ?? 'Save',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: Color(0xFF1877F2),
                    ),
                  ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 1. Profile Picture Section
            _buildSectionHeader(
              title: 'Profile Picture',
              actionLabel: 'Edit',
              onActionTap:
                  state.isUploadingAvatar ? null : _pickAndUploadAvatar,
            ),
            const SizedBox(height: 12),
            Center(
              child: GestureDetector(
                onTap: state.isUploadingAvatar ? null : _pickAndUploadAvatar,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: 58,
                      backgroundColor: theme.colorScheme.primaryContainer,
                      backgroundImage: hasAvatar
                          ? CachedNetworkImageProvider(profile.avatarUrl!)
                          : null,
                      child: !hasAvatar
                          ? Text(
                              profile?.initials ?? '?',
                              style: TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                            )
                          : null,
                    ),
                    if (state.isUploadingAvatar)
                      const CircularProgressIndicator(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),

            // 2. Cover Photo Section
            _buildSectionHeader(
              title: 'Cover Photo',
              actionLabel: 'Edit',
              onActionTap: state.isUploadingCover ? null : _pickAndUploadCover,
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: state.isUploadingCover ? null : _pickAndUploadCover,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: 150,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (hasCover)
                        CachedNetworkImage(
                          imageUrl: profile.coverUrl!,
                          fit: BoxFit.cover,
                        )
                      else
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isDark
                                  ? const [Color(0xFF1E3A8A), Color(0xFF4C1D95)]
                                  : const [
                                      Color(0xFF2563EB),
                                      Color(0xFF7C3AED),
                                    ],
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.add_photo_alternate_outlined,
                              size: 42,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      if (state.isUploadingCover)
                        const ColoredBox(
                          color: Colors.black45,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),

            // 3. Bio Section
            const Text(
              'Bio',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _bioController,
              maxLength: 500,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Describe yourself...',
                filled: true,
                fillColor: theme.cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),

            // 4. Details Section (Full Name, Location, Website)
            const Text(
              'Details',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _fullNameController,
              maxLength: 100,
              decoration: InputDecoration(
                labelText: loc?.fullNameLabel ?? 'Full Name',
                hintText: loc?.enterFullNameHint ?? 'Enter your full name',
                prefixIcon: const Icon(Icons.person_outline_rounded),
                filled: true,
                fillColor: theme.cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _locationController,
              maxLength: 255,
              decoration: InputDecoration(
                labelText: loc?.locations ?? 'Location / Hometown',
                hintText: 'e.g. Da Nang, Vietnam',
                prefixIcon: const Icon(Icons.home_outlined),
                filled: true,
                fillColor: theme.cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _websiteController,
              maxLength: 255,
              keyboardType: TextInputType.url,
              decoration: InputDecoration(
                labelText: 'Website',
                hintText: 'https://yourwebsite.com',
                prefixIcon: const Icon(Icons.link_rounded),
                filled: true,
                fillColor: theme.cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: state.isUpdatingProfile ? null : _saveProfile,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF1877F2),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  loc?.save ?? 'Save Changes',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String actionLabel,
    required VoidCallback? onActionTap,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
        ),
        TextButton(
          onPressed: onActionTap,
          child: Text(
            actionLabel,
            style: const TextStyle(
              color: Color(0xFF1877F2),
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }
}
