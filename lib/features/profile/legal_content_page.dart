import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:flatmates_app/core/theme/app_semantic_colors.dart';
import 'package:flatmates_app/core/theme/app_spacing.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../shared/presentation/flatmates_header.dart';

class LegalContentPage extends StatefulWidget {
  const LegalContentPage({
    required this.title,
    required this.url,
    super.key,
  });

  final String title;
  final String url;

  @override
  State<LegalContentPage> createState() => _LegalContentPageState();
}

class _LegalContentPageState extends State<LegalContentPage> {
  bool _launched = false;

  @override
  void initState() {
    super.initState();
    _openUrl();
  }

  Future<void> _openUrl() async {
    final uri = Uri.parse(widget.url);
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!mounted) return;
    _launched = launched;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = AppLocalizations.of(context);

    return Scaffold(
      appBar: FlatmatesHeader.backTitle(title: widget.title),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _launched
                      ? 'Opening...'
                      : locale.externalLinkUnavailable,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppSemanticColors.textSecondaryFor(theme.brightness),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
