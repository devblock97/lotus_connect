import 'package:flutter/material.dart';
import 'package:lotus_connect/core/theme/app_size.dart';

class SettingCard extends StatelessWidget {
  const SettingCard({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: AppSize.elevationNone,
      clipBehavior: Clip.antiAlias,
      shape: AppBorder.rounded(),
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      child: child,
    );
  }
}
