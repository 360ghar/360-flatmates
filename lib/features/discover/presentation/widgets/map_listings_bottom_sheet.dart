import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_semantic_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/gen/app_localizations.dart';
import '../../../shared/presentation/flatmates_empty_state.dart';
import '../../discover_repository.dart';
import 'discover_listing_card.dart';

/// Bottom draggable sheet that surfaces a horizontally-scrolling list of
/// listings overlaid on the map view. Highlights the selected property
/// via [selectedPropertyProvider] and reports the centered card back so
/// the map can recenter.
class MapListingsBottomSheet extends ConsumerWidget {
  const MapListingsBottomSheet({
    required this.listings,
    required this.scrollController,
    required this.onTap,
    required this.onLike,
    super.key,
  });

  final List<PropertyListing> listings;
  final ScrollController scrollController;
  final void Function(PropertyListing) onTap;
  final void Function(PropertyListing) onLike;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final locale = AppLocalizations.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final frostOverlayColor = isDark
        ? AppSemanticColors.frostOverlayDark
        : AppSemanticColors.frostOverlayLight;

    return DraggableScrollableSheet(
      initialChildSize: 0.35,
      minChildSize: 0.08,
      maxChildSize: 0.45,
      snap: true,
      snapSizes: const [0.08, 0.35, 0.45],
      builder: (context, sheetScrollController) {
        return Container(
          decoration: BoxDecoration(
            color: frostOverlayColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppRadius.card),
            ),
          ),
          child: SingleChildScrollView(
            controller: sheetScrollController,
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom + 76,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.sm,
                    ),
                    child: Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.2,
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      0,
                      AppSpacing.lg,
                      AppSpacing.sm,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: Text(
                        locale.clusterListingsCount(listings.length),
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppSemanticColors.textPrimaryFor(
                            theme.brightness,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 180,
                    child: listings.isEmpty
                        ? FlatmatesEmptyState(
                            title: locale.noListingsMatchFilters,
                            icon: Icons.search_off_rounded,
                          )
                        : _HorizontalCardList(
                            listings: listings,
                            scrollController: scrollController,
                            onTap: onTap,
                            onLike: onLike,
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _HorizontalCardList extends ConsumerWidget {
  const _HorizontalCardList({
    required this.listings,
    required this.scrollController,
    required this.onTap,
    required this.onLike,
  });

  final List<PropertyListing> listings;
  final ScrollController scrollController;
  final void Function(PropertyListing) onTap;
  final void Function(PropertyListing) onLike;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollUpdateNotification ||
            notification is ScrollEndNotification) {
          final offset = scrollController.offset;
          final itemWidth = 130.0 + AppSpacing.sm;
          final index = (offset / itemWidth).round().clamp(
            0,
            listings.length - 1,
          );
          final visibleItem = listings[index];
          final currentSelected = ref.read(selectedPropertyProvider);
          if (currentSelected?.id != visibleItem.id) {
            ref.read(selectedPropertyProvider.notifier).state = visibleItem;
          }
        }
        return false;
      },
      child: ListView.builder(
        controller: scrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: listings.length,
        itemBuilder: (context, index) {
          final item = listings[index];
          final selectedProperty = ref.watch(selectedPropertyProvider);
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: SizedBox(
              width: 130,
              child: DiscoverListingCard(
                item: item,
                isSelected: item.id == selectedProperty?.id,
                onTap: () => onTap(item),
                onLike: () => onLike(item),
              ),
            ),
          );
        },
      ),
    );
  }
}
