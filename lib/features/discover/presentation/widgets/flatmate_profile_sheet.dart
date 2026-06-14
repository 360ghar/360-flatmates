import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/compatibility/compatibility_ring.dart';
import '../../../../core/theme/app_semantic_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/gen/app_localizations.dart';
import '../../../chats/chats_repository.dart';
import '../../../shared/presentation/components.dart';

/// View-only flatmate profile modal. Mirrors [OwnerProfileSheet] but omits the
/// Contact CTA — used when tapping a flatmate profile card to inspect details.
class FlatmateProfileSheet extends ConsumerWidget {
  const FlatmateProfileSheet({
    required this.userId,
    this.nameFallback,
    super.key,
  });

  final int userId;
  final String? nameFallback;

  static Future<void> show({
    required BuildContext context,
    required int userId,
    String? nameFallback,
  }) {
    return FlatmatesBottomSheet.show<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) =>
          FlatmateProfileSheet(userId: userId, nameFallback: nameFallback),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(peerProfileProvider(userId));

    return profileAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.section),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => _FlatmateProfileBody(
        peerData: null,
        nameFallback: nameFallback,
        showError: true,
      ),
      // A null payload is the actual failure path (fetchPeerProfile catches
      // errors and returns null rather than throwing), so treat it like an
      // error: show the "couldn't load" hint and suppress the misleading
      // 0% match ring.
      data: (peerData) => _FlatmateProfileBody(
        peerData: peerData,
        nameFallback: nameFallback,
        showError: peerData == null,
      ),
    );
  }
}

class _FlatmateProfileBody extends StatelessWidget {
  const _FlatmateProfileBody({
    required this.peerData,
    required this.nameFallback,
    this.showError = false,
  });

  final Map<String, dynamic>? peerData;
  final String? nameFallback;
  final bool showError;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = AppLocalizations.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final name =
        peerData?['full_name'] as String? ?? nameFallback ?? 'Flatmate';
    final imageUrl = peerData?['profile_image_url'] as String?;
    final mode = peerData?['mode'] as String?;
    final city = peerData?['city'] as String?;
    final age = peerData?['age'];
    final profession = peerData?['profession'] as String?;
    final matchPercentage =
        (peerData?['match_percentage'] as num?)?.toDouble() ?? 0;

    final locationParts = [?peerData?['locality']?.toString(), ?city];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: AppSpacing.md),
        FlatmatesAvatar(name: name, imageUrl: imageUrl, size: 80),
        const SizedBox(height: AppSpacing.md),
        Text(
          name,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        if (showError) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            locale.couldNotLoadContent,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppSemanticColors.textTertiaryFor(
                isDark ? Brightness.dark : Brightness.light,
              ),
            ),
          ),
        ],
        if (mode != null) ...[
          const SizedBox(height: AppSpacing.xs),
          _ModeBadge(mode: mode, isDark: isDark),
        ],
        if (age != null || profession != null || locationParts.isNotEmpty)
          const SizedBox(height: AppSpacing.sm),
        if (age != null || profession != null)
          Text(
            [if (age != null) '$age years', ?profession].join(' · '),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppSemanticColors.textSecondaryFor(
                isDark ? Brightness.dark : Brightness.light,
              ),
            ),
          ),
        if (locationParts.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 14,
                color: AppSemanticColors.textTertiaryFor(
                  isDark ? Brightness.dark : Brightness.light,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                locationParts.join(', '),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppSemanticColors.textSecondaryFor(
                    isDark ? Brightness.dark : Brightness.light,
                  ),
                ),
              ),
            ],
          ),
        ],

        // Compatibility ring — only meaningful when we have peer data.
        if (!showError) ...[
          const SizedBox(height: AppSpacing.lg),
          CompatibilityRing(
            percentage: matchPercentage,
            size: 88,
            strokeWidth: 6,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${matchPercentage.round()}% Match',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: _matchColor(matchPercentage),
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }

  Color _matchColor(double pct) {
    if (pct >= 70) return AppSemanticColors.success;
    if (pct >= 40) return AppSemanticColors.warning;
    if (pct > 0) return AppSemanticColors.error;
    return AppSemanticColors.textTertiaryFor(Brightness.light);
  }
}

class _ModeBadge extends StatelessWidget {
  const _ModeBadge({required this.mode, required this.isDark});
  final String mode;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final label = switch (mode) {
      'co_hunter' => 'Co-Hunter',
      'room_poster' => 'Room Poster',
      'open_to_both' => 'Open to Both',
      _ => mode,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: AppSemanticColors.accent),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppSemanticColors.accent,
        ),
      ),
    );
  }
}
