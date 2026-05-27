import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/gen/app_localizations.dart';

/// Optional update dialog. Dismissal is tracked per-version so the user
/// is not repeatedly nagged for the same version.
class OptionalUpdateDialog extends StatelessWidget {
  const OptionalUpdateDialog({
    super.key,
    required this.updateUrl,
    required this.message,
    required this.onDismiss,
  });

  final String updateUrl;
  final String message;
  final VoidCallback onDismiss;

  static Future<void> show(
    BuildContext context, {
    required String updateUrl,
    required String message,
    required VoidCallback onDismiss,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => OptionalUpdateDialog(
        updateUrl: updateUrl,
        message: message,
        onDismiss: onDismiss,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(locale.optionalUpdateTitle),
      content: Text(
        message.isNotEmpty ? message : locale.optionalUpdateMessage,
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onDismiss();
          },
          child: Text(locale.optionalUpdateLater),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop();
            _launchUrl();
          },
          child: Text(locale.optionalUpdateCta),
        ),
      ],
    );
  }

  Future<void> _launchUrl() async {
    if (updateUrl.isEmpty) return;
    final uri = Uri.parse(updateUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
