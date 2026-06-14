import 'package:flutter/material.dart';
import 'package:flatmates_app/core/theme/app_semantic_colors.dart';

import '../../../../l10n/gen/app_localizations.dart';
import 'search_filter_widgets.dart';

/// Pets + smoking preferences, rendered as flat compact sections that match
/// the other filter groups (no card chrome) for full visual uniformity.
class MoreFiltersCard extends StatelessWidget {
  const MoreFiltersCard({
    required this.selectedPets,
    required this.selectedSmoking,
    required this.onPetsChanged,
    required this.onSmokingChanged,
    required this.catalogOrFallback,
    super.key,
  });

  final String? selectedPets;
  final String? selectedSmoking;
  final void Function(String?) onPetsChanged;
  final void Function(String?) onSmokingChanged;
  final List<({String id, String label})> Function(String, List<String>)
  catalogOrFallback;

  String _petsSubtitle(AppLocalizations locale) {
    return switch (selectedPets) {
      'yes' => locale.petsYes,
      'no' => locale.petsNo,
      _ => locale.petsNoPreference,
    };
  }

  String _smokingSubtitle(AppLocalizations locale) {
    return switch (selectedSmoking) {
      'yes' => locale.smokingYes,
      'no' => locale.smokingNo,
      _ => locale.smokingNoPreference,
    };
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CompactFilterSection(
          title: locale.petsLabel,
          subtitle: _petsSubtitle(locale),
          icon: Icons.pets_outlined,
          iconColor: AppSemanticColors.orangeMid,
          iconBgColor: AppSemanticColors.orangeSoft,
          child: CatalogFilterChips(
            options: catalogOrFallback('flatmates_pets_options', [
              'no_preference',
              'yes',
              'no',
            ]),
            selectedId: selectedPets ?? 'no_preference',
            anyKey: 'no_preference',
            onSelected: (id) =>
                onPetsChanged(id == 'no_preference' ? null : id),
          ),
        ),
        CompactFilterSection(
          title: locale.smokingLabel,
          subtitle: _smokingSubtitle(locale),
          icon: Icons.smoke_free_outlined,
          iconColor: AppSemanticColors.purpleMid,
          iconBgColor: AppSemanticColors.purpleSoft,
          child: CatalogFilterChips(
            options: catalogOrFallback('flatmates_smoking_options', [
              'no_preference',
              'no',
              'yes',
            ]),
            selectedId: selectedSmoking ?? 'no_preference',
            anyKey: 'no_preference',
            onSelected: (id) =>
                onSmokingChanged(id == 'no_preference' ? null : id),
          ),
        ),
      ],
    );
  }
}
