import 'package:flutter/material.dart';

/// App-wide icon constants for search & filter affordances, so every screen
/// stays visually consistent.
///
/// Use [AppIcons.search] for any control that opens a text search, and
/// [AppIcons.filter] for any control that opens the filter sheet / filter UI.
/// Do NOT use these for "no results" illustrations (those use `search_off_*`).
abstract final class AppIcons {
  const AppIcons._();

  /// Canonical search affordance icon.
  static const IconData search = Icons.search_rounded;

  /// Canonical filter affordance icon.
  static const IconData filter = Icons.tune_rounded;
}
