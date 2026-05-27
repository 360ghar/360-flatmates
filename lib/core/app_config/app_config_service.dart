import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../analytics/analytics_service.dart';
import '../config/endpoints.dart';
import '../providers.dart';

enum AppUpdateStatus { upToDate, optionalUpdate, forceUpdate }

class RemoteAppConfig {
  const RemoteAppConfig({
    required this.platform,
    required this.latestVersion,
    required this.minimumRequiredVersion,
    required this.forceUpdate,
    required this.updateUrl,
    required this.maintenanceEnabled,
    required this.maintenanceMessage,
    required this.optionalUpdateMessage,
  });

  final String platform;
  final String latestVersion;
  final String minimumRequiredVersion;
  final bool forceUpdate;
  final String updateUrl;
  final bool maintenanceEnabled;
  final String maintenanceMessage;
  final String optionalUpdateMessage;

  factory RemoteAppConfig.fromJson(Map<String, dynamic> json) {
    return RemoteAppConfig(
      platform: json['platform'] as String? ?? '',
      latestVersion: json['latest_version'] as String? ?? '0.0.0',
      minimumRequiredVersion:
          json['minimum_required_version'] as String? ?? '0.0.0',
      forceUpdate: json['force_update'] as bool? ?? false,
      updateUrl: json['update_url'] as String? ?? '',
      maintenanceEnabled: json['maintenance_enabled'] as bool? ?? false,
      maintenanceMessage: json['maintenance_message'] as String? ?? '',
      optionalUpdateMessage: json['optional_update_message'] as String? ?? '',
    );
  }
}

class AppConfigService {
  AppConfigService({required this.ref});

  final Ref ref;
  static const _dismissedVersionKey = 'optional_update_dismissed_version';

  Future<RemoteAppConfig?> fetchConfig() async {
    try {
      final response = await ref
          .read(apiClientProvider)
          .get(
            FlatmatesEndpoints.appConfig,
            queryParameters: {'platform': defaultTargetPlatform.name},
            // 404 is expected when the endpoint isn't deployed yet — accept
            // it as a valid response so Dio doesn't throw and pollute logs.
            options: Options(
              validateStatus: (status) =>
                  status != null && (status < 300 || status == 404),
            ),
          );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return RemoteAppConfig.fromJson(data);
      }
      return null;
    } catch (e, st) {
      try {
        ref.read(analyticsServiceProvider).recordError(e, st);
      } catch (_) {}
      return null;
    }
  }

  Future<AppUpdateStatus> checkUpdateStatus(RemoteAppConfig config) async {
    final packageInfo = await PackageInfo.fromPlatform();
    final installed = packageInfo.version;

    final belowMinimum =
        _compareSemver(installed, config.minimumRequiredVersion) < 0;
    if (belowMinimum || config.forceUpdate) {
      return AppUpdateStatus.forceUpdate;
    }

    final belowLatest = _compareSemver(installed, config.latestVersion) < 0;
    if (belowLatest) {
      // Check if user already dismissed this version.
      final prefs = ref.read(appPreferencesProvider);
      final dismissed = prefs.getString(_dismissedVersionKey);
      if (dismissed == config.latestVersion) {
        return AppUpdateStatus.upToDate;
      }
      return AppUpdateStatus.optionalUpdate;
    }

    return AppUpdateStatus.upToDate;
  }

  Future<void> dismissOptionalUpdate(String version) async {
    final prefs = ref.read(appPreferencesProvider);
    await prefs.setString(_dismissedVersionKey, version);
  }

  /// Returns negative if [a] < [b], 0 if equal, positive if [a] > [b].
  /// Returns 0 if either version string is malformed.
  int _compareSemver(String a, String b) {
    List<int>? partsA;
    List<int>? partsB;
    try {
      partsA = a.split('.').map(int.parse).toList();
    } catch (_) {
      partsA = null;
    }
    try {
      partsB = b.split('.').map(int.parse).toList();
    } catch (_) {
      partsB = null;
    }
    if (partsA == null || partsB == null) return 0;
    for (var i = 0; i < 3; i++) {
      final valA = i < partsA.length ? partsA[i] : 0;
      final valB = i < partsB.length ? partsB[i] : 0;
      if (valA != valB) return valA.compareTo(valB);
    }
    return 0;
  }
}

final appConfigServiceProvider = Provider<AppConfigService>(
  (ref) => AppConfigService(ref: ref),
);
