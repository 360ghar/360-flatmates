import 'package:flutter/material.dart';
import 'package:flatmates_app/core/theme/app_semantic_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/config/constants.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/app_spacing.dart';
import '../../l10n/gen/app_localizations.dart';
import '../auth/auth_controller.dart';
import '../bootstrap/bootstrap_controller.dart';
import 'settings_controller.dart';
import '../shared/presentation/components.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = AppLocalizations.of(context);

    return FlatmatesScreen(
      appBar: FlatmatesHeader.backTitle(
        title: locale.settingsTitle,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Scrollable content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.md,
              ),
              children: [
                // Account group
                _SectionHeader(label: locale.settingsGroupAccount),
                FlatmatesCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FlatmatesMenuItem(
                        icon: Icons.person_outline,
                        label: locale.editProfileCta,
                        onTap: () => context.push('/profile/edit'),
                      ),
                      const Divider(
                        height: 1,
                        indent: AppSpacing.xl * 3 + AppSpacing.sm,
                        endIndent: AppSpacing.lg,
                      ),
                      FlatmatesMenuItem(
                        icon: Icons.lock_outline,
                        label: locale.changePasswordLabel,
                        onTap: () => context.push('/change-password'),
                      ),
                      const Divider(
                        height: 1,
                        indent: AppSpacing.xl * 3 + AppSpacing.sm,
                        endIndent: AppSpacing.lg,
                      ),
                      FlatmatesMenuItem(
                        icon: Icons.shield_outlined,
                        label: locale.privacySecurityLabel,
                        onTap: () => context.push('/help-safety'),
                      ),
                      const Divider(
                        height: 1,
                        indent: AppSpacing.xl * 3 + AppSpacing.sm,
                        endIndent: AppSpacing.lg,
                      ),
                      FlatmatesMenuItem(
                        key: const Key('preferences_menu_item'),
                        icon: Icons.tune,
                        label: locale.preferencesLabel,
                        onTap: () => _showPreferences(context, ref),
                      ),
                      const Divider(
                        height: 1,
                        indent: AppSpacing.xl * 3 + AppSpacing.sm,
                        endIndent: AppSpacing.lg,
                      ),
                      FlatmatesMenuItem(
                        key: const Key('delete_account_menu_item'),
                        icon: Icons.delete_forever_outlined,
                        label: locale.deleteAccountCta,
                        isDestructive: true,
                        onTap: () => _showDeleteAccountDialog(context, ref),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.section),

                // App group
                _SectionHeader(label: locale.settingsGroupApp),
                FlatmatesCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FlatmatesMenuItem(
                        icon: Icons.notifications_outlined,
                        label: locale.notificationSettingsLabel,
                        onTap: () => context.push('/notification-settings'),
                      ),
                      const Divider(
                        height: 1,
                        indent: AppSpacing.xl * 3 + AppSpacing.sm,
                        endIndent: AppSpacing.lg,
                      ),
                      FlatmatesMenuItem(
                        icon: Icons.person_off_outlined,
                        label: locale.blockedUsersLabel,
                        onTap: () => context.push('/blocked-users'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.section),

                // Legal group
                _SectionHeader(label: locale.settingsGroupLegal),
                FlatmatesCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FlatmatesMenuItem(
                        icon: Icons.info_outline,
                        label: locale.aboutLabel,
                        onTap: () => _showAboutDialog(context),
                      ),
                      const Divider(
                        height: 1,
                        indent: AppSpacing.xl * 3 + AppSpacing.sm,
                        endIndent: AppSpacing.lg,
                      ),
                      FlatmatesMenuItem(
                        icon: Icons.policy_outlined,
                        label: locale.privacyPolicy,
                        onTap: () => context.push('/privacy-policy'),
                      ),
                      const Divider(
                        height: 1,
                        indent: AppSpacing.xl * 3 + AppSpacing.sm,
                        endIndent: AppSpacing.lg,
                      ),
                      FlatmatesMenuItem(
                        icon: Icons.description_outlined,
                        label: locale.termsAndConditionsLabel,
                        onTap: () => context.push('/terms-of-service'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.section),

                // Standalone Logout
                FlatmatesButton.tertiary(
                  key: const Key('logout_button'),
                  label: locale.logoutCta,
                  destructive: true,
                  onPressed: () =>
                      ref.read(authControllerProvider.notifier).signOut(),
                ),

                const SizedBox(height: AppSpacing.screen),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showPreferences(BuildContext context, WidgetRef ref) {
    FlatmatesBottomSheet.show(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) =>
          Consumer(builder: (context, ref, _) => const _PreferencesSheet()),
    );
  }

  void _showAboutDialog(BuildContext context) {
    final locale = AppLocalizations.of(context);
    showAboutDialog(
      context: context,
      applicationName: locale.appName,
      applicationVersion: '1.0.3',
      applicationIcon: const FlutterLogo(size: 32),
    );
  }

  Future<void> _showDeleteAccountDialog(BuildContext context, WidgetRef ref) async {
    final locale = AppLocalizations.of(context);
    const emailSubject = 'Account Deletion Request';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(locale.deleteAccountTitle),
        content: Text(locale.deleteAccountWarning),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(locale.cancelCta),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppSemanticColors.error),
            child: Text(locale.deleteAccountCta),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final registeredEmail =
        ref.read(bootstrapControllerProvider).valueOrNull?.profile.email?.trim();
    final emailLine = (registeredEmail != null && registeredEmail.isNotEmpty)
        ? registeredEmail
        : 'Not available';
    final body = 'Hello 360 Ghar Support,\n\n'
        'I would like to request the deletion of my account.\n\n'
        'Registered email: $emailLine\n\n'
        'Thank you.';
    final uri = Uri(
      scheme: 'mailto',
      path: kSupportEmail,
      queryParameters: <String, String>{
        'subject': emailSubject,
        'body': body,
      },
    );

    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!context.mounted) return;
      if (launched) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(locale.deleteAccountRequestSent)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              locale.deleteAccountEmailFallback(kSupportEmail, emailSubject),
            ),
          ),
        );
      }
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            locale.deleteAccountEmailFallback(kSupportEmail, emailSubject),
          ),
        ),
      );
    }
  }
}

/// Bottom sheet for Preferences — holds theme mode, palette, and language
/// selectors that were moved out of the main settings page.
class _PreferencesSheet extends StatelessWidget {
  const _PreferencesSheet();

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final settings = ref.watch(settingsControllerProvider);
        final locale = AppLocalizations.of(context);
        final theme = Theme.of(context);

        if (!settings.loaded) {
          return DraggableScrollableSheet(
            initialChildSize: 0.4,
            expand: false,
            builder: (context, scrollController) {
              return const Center(child: CircularProgressIndicator());
            },
          );
        }

        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: AppSpacing.sm),
                  width: AppSpacing.xl,
                  height: AppSpacing.xs,
                  decoration: BoxDecoration(
                    color: AppSemanticColors.line.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(AppSpacing.xs),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.sm,
                  ),
                  child: Text(
                    locale.preferencesLabel,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Divider(),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.sm,
                      AppSpacing.lg,
                      AppSpacing.xl,
                    ),
                    children: [
                      Text(
                        locale.themeModeTitle,
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      FlatmatesSegmentedControl<ThemeMode>(
                        segments: [
                          (
                            ThemeMode.system,
                            locale.themeSystem,
                            Icons.brightness_auto_outlined,
                          ),
                          (
                            ThemeMode.light,
                            locale.themeLight,
                            Icons.light_mode_outlined,
                          ),
                          (
                            ThemeMode.dark,
                            locale.themeDark,
                            Icons.dark_mode_outlined,
                          ),
                        ],
                        selected: settings.themeMode,
                        onChanged: (value) {
                          ref
                              .read(settingsControllerProvider.notifier)
                              .updateThemeMode(value);
                        },
                        segmentKeys: const [
                          Key('theme_mode_system_option'),
                          Key('theme_mode_light_option'),
                          Key('theme_mode_dark_option'),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      Text(
                        locale.paletteTitle,
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: AppPalette.values.map((palette) {
                          final selected = settings.palette == palette;
                          return FlatmatesChip(
                            key: Key('palette_${palette.storageValue}'),
                            label: _paletteLabel(locale, palette),
                            variant: FlatmatesChipVariant.choice,
                            selected: selected,
                            onSelected: (_) {
                              ref
                                  .read(settingsControllerProvider.notifier)
                                  .updatePalette(palette);
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      Text(
                        locale.languageTitle,
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      FlatmatesSegmentedControl<String>(
                        segments: [
                          ('en', locale.languageEnglish, null),
                          ('hi', locale.languageHindi, null),
                        ],
                        selected: settings.locale?.languageCode ?? 'en',
                        onChanged: (value) {
                          ref
                              .read(settingsControllerProvider.notifier)
                              .updateLocale(Locale(value));
                        },
                        segmentKeys: const [
                          Key('language_english_option'),
                          Key('language_hindi_option'),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      Material(
                        color: Colors.transparent,
                        child: SwitchListTile(
                          key: const Key('setting_hide_last_name'),
                          secondary: Icon(
                            Icons.person_off_outlined,
                            color: AppSemanticColors.accent,
                          ),
                          title: Text(locale.hideLastNameLabel),
                          value: settings.hideLastName,
                          onChanged: (v) {
                            ref
                                .read(settingsControllerProvider.notifier)
                                .updateHideLastName(v);
                          },
                        ),
                      ),
                      const Divider(),
                      Material(
                        color: Colors.transparent,
                        child: SwitchListTile(
                          key: const Key('setting_hide_location'),
                          secondary: Icon(
                            Icons.location_off_outlined,
                            color: AppSemanticColors.accent,
                          ),
                          title: Text(locale.hideExactLocationLabel),
                          value: settings.hideExactLocation,
                          onChanged: (v) {
                            ref
                                .read(settingsControllerProvider.notifier)
                                .updateHideExactLocation(v);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

String _paletteLabel(AppLocalizations locale, AppPalette palette) {
  switch (palette) {
    case AppPalette.inkOnPaper:
      return locale.paletteInkOnPaper;
    case AppPalette.electricIndigo:
      return locale.paletteElectricIndigo;
    case AppPalette.emberCoral:
      return locale.paletteEmberCoral;
    case AppPalette.monsoonTeal:
      return locale.paletteMonsoonTeal;
  }
}

/// Section group header with a divider line above and bold label.
/// Matches DESIGN.md Screen 19 group pattern.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 1),
          const SizedBox(height: AppSpacing.md),
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppSemanticColors.textSecondaryFor(theme.brightness),
            ),
          ),
        ],
      ),
    );
  }
}
