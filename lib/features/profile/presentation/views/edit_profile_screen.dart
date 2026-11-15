import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lotus_connect/app/theme/app_color.dart';
import 'package:lotus_connect/app/theme/app_size.dart';
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
      final loc = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? (loc?.profilePictureUpdated ?? 'Profile picture updated!')
                : (loc?.failedToUploadAvatar ??
                    'Failed to upload profile picture.'),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: success
              ? AppColor.successGreen.of(context)
              : AppColor.danger.of(context),
        ),
      );
    } on Object catch (e) {
      if (!mounted) return;
      final loc = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            loc?.failedToPickImage(e.toString()) ?? 'Failed to pick image: $e',
          ),
        ),
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
      final loc = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? (loc?.coverPhotoUpdated ?? 'Cover photo updated!')
                : (loc?.failedToUploadCover ?? 'Failed to upload cover photo.'),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: success
              ? AppColor.successGreen.of(context)
              : AppColor.danger.of(context),
        ),
      );
    } on Object catch (e) {
      if (!mounted) return;
      final loc = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            loc?.failedToPickImage(e.toString()) ?? 'Failed to pick image: $e',
          ),
        ),
      );
    }
  }

  Future<ImageSource?> _showImageSourceSheet() {
    final loc = AppLocalizations.of(context);
    return showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadius.bottomSheetTop,
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppGap.vMd,
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: Text(loc?.chooseFromGallery ?? 'Choose from Gallery'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded),
              title: Text(loc?.takeAPhoto ?? 'Take a Photo'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            AppGap.vSm,
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
    final loc = AppLocalizations.of(context);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            loc?.profileUpdatedSuccess ?? 'Profile updated successfully!',
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColor.successGreen.of(context),
        ),
      );
      Navigator.pop(context, true);
    } else {
      final err = ref.read(myProfileNotifierProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            err ?? (loc?.failedToUpdateProfile ?? 'Failed to update profile'),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColor.danger.of(context),
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
                    width: AppSize.loaderSizeSm,
                    height: AppSize.loaderSizeSm,
                    child: CircularProgressIndicator(
                      strokeWidth: AppSize.borderThick,
                    ),
                  )
                : Text(
                    loc?.save ?? 'Save',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: AppColor.socialBlue.of(context),
                    ),
                  ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: AppPadding.screen,
          children: [
            // 1. Profile Picture Section
            _buildSectionHeader(
              context: context,
              title: loc?.profilePicture ?? 'Profile Picture',
              actionLabel: loc?.edit ?? 'Edit',
              onActionTap:
                  state.isUploadingAvatar ? null : _pickAndUploadAvatar,
            ),
            AppGap.vMd,
            Center(
              child: GestureDetector(
                onTap: state.isUploadingAvatar ? null : _pickAndUploadAvatar,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: AppSize.avatarProfile / 2,
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
            AppGap.vXl,
            const Divider(),
            AppGap.vMd,

            // 2. Cover Photo Section
            _buildSectionHeader(
              context: context,
              title: loc?.coverPhoto ?? 'Cover Photo',
              actionLabel: loc?.edit ?? 'Edit',
              onActionTap: state.isUploadingCover ? null : _pickAndUploadCover,
            ),
            AppGap.vMd,
            GestureDetector(
              onTap: state.isUploadingCover ? null : _pickAndUploadCover,
              child: ClipRRect(
                borderRadius: AppRadius.media,
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
                              colors: [
                                AppColor.profileCoverStart.of(context),
                                AppColor.profileCoverEnd.of(context),
                              ],
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.add_photo_alternate_outlined,
                              size: AppSize.iconXxl,
                              color: AppColor.onMedia70.of(context),
                            ),
                          ),
                        ),
                      if (state.isUploadingCover)
                        ColoredBox(
                          color: AppColor.mediaScrim45.of(context),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColor.onMedia.of(context),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            AppGap.vXl,
            const Divider(),
            AppGap.vMd,

            // 3. Bio Section
            Text(
              loc?.bioLabel ?? 'Bio',
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),
            AppGap.vSm,
            TextFormField(
              controller: _bioController,
              maxLength: 500,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: loc?.bioHint ?? 'Describe yourself...',
                filled: true,
                fillColor: theme.cardColor,
                border: const OutlineInputBorder(
                  borderRadius: AppRadius.input,
                ),
              ),
            ),
            AppGap.vMd,
            const Divider(),
            AppGap.vMd,

            // 4. Details Section (Full Name, Location, Website)
            Text(
              loc?.detailsSectionTitle ?? 'Details',
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),
            AppGap.vLg,
            TextFormField(
              controller: _fullNameController,
              maxLength: 100,
              decoration: InputDecoration(
                labelText: loc?.fullNameLabel ?? 'Full Name',
                hintText: loc?.enterFullNameHint ?? 'Enter your full name',
                prefixIcon: const Icon(Icons.person_outline_rounded),
                filled: true,
                fillColor: theme.cardColor,
                border: const OutlineInputBorder(
                  borderRadius: AppRadius.input,
                ),
              ),
            ),
            AppGap.vMd,
            TextFormField(
              controller: _locationController,
              maxLength: 255,
              decoration: InputDecoration(
                labelText: loc?.locationHometownLabel ?? 'Location / Hometown',
                hintText: loc?.locationHint ?? 'e.g. Da Nang, Vietnam',
                prefixIcon: const Icon(Icons.home_outlined),
                filled: true,
                fillColor: theme.cardColor,
                border: const OutlineInputBorder(
                  borderRadius: AppRadius.input,
                ),
              ),
            ),
            AppGap.vMd,
            TextFormField(
              controller: _websiteController,
              maxLength: 255,
              keyboardType: TextInputType.url,
              decoration: InputDecoration(
                labelText: loc?.websiteRowLabel ?? 'Website',
                hintText: loc?.websiteHint ?? 'https://yourwebsite.com',
                prefixIcon: const Icon(Icons.link_rounded),
                filled: true,
                fillColor: theme.cardColor,
                border: const OutlineInputBorder(
                  borderRadius: AppRadius.input,
                ),
              ),
            ),
            AppGap.vXxl,
            SizedBox(
              width: double.infinity,
              height: AppSize.minTouchTarget,
              child: FilledButton(
                onPressed: state.isUpdatingProfile ? null : _saveProfile,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColor.socialBlue.of(context),
                  foregroundColor: AppColor.onMedia.of(context),
                  shape: AppBorder.rounded(radius: AppSize.radiusButton),
                ),
                child: Text(
                  loc?.saveChanges ?? 'Save Changes',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            AppGap.vXxxl,
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required BuildContext context,
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
            style: TextStyle(
              color: AppColor.socialBlue.of(context),
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }
}
