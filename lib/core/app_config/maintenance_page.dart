import 'package:flutter/material.dart';

import '../../l10n/gen/app_localizations.dart';
import '../theme/app_semantic_colors.dart';

/// Full-screen maintenance mode page. Shown when [maintenance_enabled] is true
/// in the remote app_config.
class MaintenancePage extends StatelessWidget {
  const MaintenancePage({super.key, this.message, this.onRetry});

  final String? message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.build_outlined,
                  size: 64,
                  color: AppSemanticColors.textTertiary,
                ),
                const SizedBox(height: 24),
                Text(
                  locale.maintenanceTitle,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  message?.isNotEmpty == true
                      ? message!
                      : locale.maintenanceMessage,
                  style: TextStyle(
                    fontSize: 15,
                    color: AppSemanticColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (onRetry != null) ...[
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: onRetry,
                      child: Text(locale.maintenanceRetry),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
