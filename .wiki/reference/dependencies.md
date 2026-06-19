# Dependencies

All Flutter/Dart package dependencies for 360 FlatMates, with version ranges from `pubspec.yaml`.

## Runtime dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `app_links` | ^6.3.3 | Deep link handling (iOS Universal Links, Android App Links) |
| `cached_network_image` | ^3.4.1 | Image caching and placeholder support |
| `connectivity_plus` | ^6.1.4 | Network connectivity monitoring |
| `cupertino_icons` | ^1.0.8 | iOS-style icons |
| `crypto` | ^3.0.6 | Cryptographic hashing utilities |
| `dio` | ^5.9.0 | HTTP client with interceptors |
| `firebase_analytics` | ^11.6.0 | Event analytics and screen tracking |
| `firebase_core` | ^3.14.0 | Firebase SDK initialization |
| `firebase_crashlytics` | ^4.3.10 | Crash reporting and error logging |
| `firebase_messaging` | ^15.2.9 | Push notifications (FCM) |
| `flutter_dotenv` | ^5.2.1 | Environment variable loading from `.env` files |
| `flutter_local_notifications` | ^18.0.1 | Local notification display |
| `flutter_map` | ^8.3.0 | OpenStreetMap-based map widget |
| `flutter_map_cache` | ^1.4.0 | Tile caching for flutter_map |
| `flutter_riverpod` | ^2.6.1 | State management (providers, notifiers) |
| `flutter_secure_storage` | ^9.2.4 | Encrypted key-value storage (Keychain / EncryptedSharedPrefs) |
| `freezed_annotation` | ^2.4.4 | Annotations for Freezed code generation |
| `geocoding` | ^3.0.0 | Address-to-coordinate conversion |
| `geolocator` | ^13.0.2 | Device GPS location access |
| `go_router` | ^16.2.1 | Declarative routing with redirect chains |
| `google_fonts` | ^6.3.2 | Google Fonts (Fraunces, Inter, JetBrains Mono, Instrument Serif) |
| `google_sign_in` | ^7.2.0 | Google OAuth sign-in |
| `http` | ^1.3.0 | HTTP client (used alongside Dio) |
| `image_picker` | ^1.1.2 | Camera and gallery image/video picking |
| `intl` | ^0.20.2 | Internationalization utilities |
| `json_annotation` | ^4.9.0 | Annotations for json_serializable code generation |
| `latlong2` | ^0.9.1 | Latitude/longitude coordinate types |
| `package_info_plus` | ^8.3.0 | App version and build number |
| `path_provider` | ^2.1.5 | File system directory paths |
| `share_plus` | ^10.1.4 | Native share sheet |
| `shared_preferences` | ^2.5.3 | Key-value persistent storage |
| `sign_in_with_apple` | ^8.1.0 | Apple OAuth sign-in |
| `smart_auth` | ^3.2.0 | SMS autofill for OTP |
| `sms_autofill` | ^2.3.0 | SMS autofill support |
| `supabase_flutter` | ^2.10.4 | Supabase client (auth, realtime, database) |
| `confetti` | ^0.7.0 | Confetti animation (match celebration) |
| `flutter_markdown` | ^0.7.4+1 | Markdown rendering (legal pages, help content) |
| `qr_flutter` | ^4.1.0 | QR code generation |
| `video_player` | ^2.11.1 | Video playback and duration detection |
| `stack_trace` | ^1.12.1 | Stack trace formatting |
| `url_launcher` | ^6.3.1 | Opening URLs in browser/phone/email |

## Dev dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `build_runner` | ^2.4.14 | Code generation runner |
| `very_good_analysis` | ^6.0.0 | Strict lint rules |
| `flutter_native_splash` | ^2.4.0 | Native splash screen generation |
| `flutter_test` | (SDK) | Unit and widget testing |
| `flutter_launcher_icons` | ^0.14.3 | App icon generation |
| `freezed` | ^2.5.8 | Immutable data class code generation |
| `json_serializable` | ^6.9.4 | JSON serialization code generation |
| `riverpod_lint` | ^2.3.0 | Riverpod-specific lint rules |
| `flutter_lints` | ^6.0.0 | Flutter lint rules |

## SDK constraints

| SDK | Version |
|-----|---------|
| Dart | ^3.9.0 |
| Flutter | >=3.35.0 |

## Key architectural dependencies

- **Riverpod** -- all state management. `NotifierProvider`, `AsyncNotifierProvider`, `FamilyNotifier`, `StateProvider`, `StreamProvider`, `FutureProvider`.
- **GoRouter** -- declarative routing with `StatefulShellRoute.indexedStack` for tabbed navigation.
- **Dio** -- HTTP client with interceptor chain (auth token, error mapping, logging).
- **Supabase** -- authentication (phone, OTP, Google, Apple), realtime subscriptions for chat.
- **Firebase** -- push notifications, analytics, crash reporting.
- **Freezed + json_serializable** -- immutable domain models with JSON serialization.
- **Google Fonts** -- Fraunces (headlines), Inter (body), JetBrains Mono (eyebrow), Instrument Serif (italic).
