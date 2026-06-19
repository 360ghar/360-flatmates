# Systems

This section documents the cross-cutting infrastructure that powers 360 FlatMates. Each page covers a subsystem that lives under `lib/core/` and is consumed by feature modules in `lib/features/`.

| System | Description | Key files |
|--------|-------------|-----------|
| [Networking](networking.md) | Dio-based HTTP client, auth token management, error mapping, connectivity monitoring | `lib/core/network/` |
| [Realtime](realtime.md) | Server-Sent Events stream, Supabase realtime subscriptions, provider invalidation routing | `lib/core/network/sse_service.dart`, `lib/core/network/sse_providers.dart` |
| [Routing](routing.md) | GoRouter configuration, auth redirect chain, deep link handling, mode-dependent tab switching | `lib/app/router/app_router.dart` |
| [Theme & Design](theme-and-design.md) | Material 3 theming, color palettes, typography, spacing, shadows, motion tokens | `lib/core/theme/` |
| [Error Handling](error-handling.md) | Typed failure hierarchy, Dio-to-AppFailure mapping, localized error messages, async state views | `lib/core/errors/` |
| [Compatibility](compatibility.md) | Client-side matching algorithm with 6 weighted dimensions, animated ring widget | `lib/core/compatibility/` |
| [Analytics & Storage](analytics-and-storage.md) | Firebase Analytics + Crashlytics, shared preferences, secure key-value storage, image upload | `lib/core/analytics/`, `lib/core/storage/` |
| [Push & Deep Links](push-and-deep-links.md) | Firebase Cloud Messaging, local notifications, deep link routing, app config, API endpoints | `lib/core/notifications/`, `lib/core/deep_links/`, `lib/core/config/` |

## Directory layout

```text
lib/core/
  analytics/          Firebase Analytics + Crashlytics service
  app_config/         Version check, force/optional update flows
  compatibility/      Matching engine + ring widget
  config/             AppConfig, FlatmatesEndpoints, constants, env loader
  deep_links/         DeepLinkService (app_links)
  domain/             PagedState, OptimisticUpdate, typed enums
  errors/             AppFailure sealed class, ErrorPresenter, l10n bridge
  location/           Geolocator + geocoding helpers
  map/                Flutter map configuration
  network/            ApiClient, AuthInterceptor, SSE service, connectivity
  notifications/      NotificationService (FCM + local notifications)
  providers.dart      Global Riverpod provider graph (7 root providers)
  storage/            AppPreferences, SecureKvStore, AuthTokenStorage, image upload
  theme/              Material 3 theme, design tokens, palette switching
  utils/              ActionDebouncer
  widgets/            Shared cross-feature widgets
```

## Architecture principles

- **`lib/core` is plumbing only.** No feature logic leaks here. Feature-specific behavior belongs in `lib/features/`.
- **Single Dio client.** All authenticated HTTP flows through `apiClientProvider` with the shared `AuthInterceptor`.
- **Three overridden providers at root.** `appConfigProvider`, `appPreferencesProvider`, and `secureStoreProvider` are injected via `ProviderScope` overrides in `bootstrap.dart`.
- **Typed errors everywhere.** Repositories throw `AppFailure` subclasses, never raw strings or `DioException` to the UI.
- **Reactive invalidation.** SSE events and Supabase realtime changes invalidate Riverpod providers; the UI rebuilds automatically.
