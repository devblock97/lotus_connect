import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/app/theme/app_size.dart';
import 'package:lotus_connect/features/contacts/application/friend_request_notifier.dart';
import 'package:lotus_connect/features/contacts/presentation/widgets/request_card.dart';
import 'package:lotus_connect/l10n/app_localizations.dart';

class AllFriendRequestsScreen extends ConsumerStatefulWidget {
  const AllFriendRequestsScreen({super.key});

  @override
  ConsumerState<AllFriendRequestsScreen> createState() =>
      _AllFriendRequestsScreenState();
}

class _AllFriendRequestsScreenState
    extends ConsumerState<AllFriendRequestsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(friendRequestProvider.notifier).loadFriendRequests();
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final state = ref.watch(friendRequestProvider);

    final theme = Theme.of(context);

    if (state.isLoading && state.requests.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.requests.isEmpty) {
      return RefreshIndicator(
        onRefresh: () =>
            ref.read(friendRequestProvider.notifier).loadFriendRequests(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppSize.giant + AppSize.lg,
                horizontal: AppSize.xxl,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_add_disabled_outlined,
                      size: AppSize.iconHero,
                      color: theme.colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.4),
                    ),
                    AppGap.vLg,
                    Text(
                      loc.noPendingRequests,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(friendRequestProvider.notifier).loadFriendRequests(),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSize.screenPadding,
          vertical: AppSize.md,
        ),
        itemCount: state.requests.length,
        itemBuilder: (context, index) {
          return RequestCard(user: state.requests[index]);
        },
      ),
    );
  }
}
