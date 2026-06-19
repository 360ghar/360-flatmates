# Configuration

## Environment variables

The app loads configuration from `--dart-define` flags first, falling back to a `.env` file loaded by `flutter_dotenv`. If required variables are missing, the app shows a configuration error screen.

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `API_BASE_URL` | Yes | -- | Backend API base URL (e.g., `https://api.360ghar.com`) |
| `SUPABASE_URL` | Yes | -- | Supabase project URL |
| `SUPABASE_PUBLISHABLE_KEY` | Yes | -- | Supabase anonymous/public key |
| `APP_ENV` | No | `dev` | Environment: `dev`, `staging`, `prod` |
| `ENABLE_DEBUG_LOGS` | No | `true` (debug) / `false` (release) | Enable debug logging |
| `GOOGLE_WEB_CLIENT_ID` | No | `''` | Google OAuth web client ID |
| `GOOGLE_IOS_CLIENT_ID` | No | `''` | Google OAuth iOS client ID |

### Setup

```bash
cp .env.example .env
# Fill in API_BASE_URL, SUPABASE_URL, SUPABASE_PUBLISHABLE_KEY
```

Or pass via `--dart-define`:
```bash
flutter run --dart-define=API_BASE_URL=https://api.example.com \
            --dart-define=SUPABASE_URL=https://xxx.supabase.co \
            --dart-define=SUPABASE_PUBLISHABLE_KEY=eyJ...
```

## AppConfig fields

**File:** `lib/core/config/app_config.dart`

| Field | Type | Source |
|-------|------|--------|
| `environment` | `AppEnvironment` | `APP_ENV` |
| `apiBaseUrl` | `String` | `API_BASE_URL` |
| `supabaseUrl` | `String` | `SUPABASE_URL` |
| `supabaseAnonKey` | `String` | `SUPABASE_PUBLISHABLE_KEY` |
| `enableDebugLogs` | `bool` | `ENABLE_DEBUG_LOGS` |
| `googleWebClientId` | `String` | `GOOGLE_WEB_CLIENT_ID` |
| `googleIosClientId` | `String` | `GOOGLE_IOS_CLIENT_ID` |
| `isGoogleSignInConfigured` | `bool` (computed) | `true` when `googleWebClientId` is non-empty |

### AppEnvironment enum

| Value | Description |
|-------|-------------|
| `dev` | Development (default) |
| `staging` | Staging environment |
| `prod` | Production |

## FlatmatesEndpoints

**File:** `lib/core/config/endpoints.dart`

All API path constants. Repositories must use these instead of inline path strings.

### Auth / User

| Constant | Path | Description |
|----------|------|-------------|
| `me` | `/users/me` | Current user profile |
| `authState` | `/users/me/auth-state?app=flatmates` | Auth state for flatmates app |
| `deleteAccount` | `/users/me` | DELETE account |
| `userLocation` | `/users/location` | Update user location |
| `identifierStatus` | `/auth/identifier-status` | Check identifier availability |
| `lastMethod` | `/auth/last-method` | Last auth method used |
| `authConfig` | `/auth/config` | Auth configuration |

### Bootstrap & Profile

| Constant | Path | Description |
|----------|------|-------------|
| `bootstrap` | `/flatmates/bootstrap` | Profile + catalogs + counts |
| `profile` | `/flatmates/profile` | User profile CRUD |
| `catalogs` | `/flatmates/catalogs` | Server-driven metadata |

### Blocks

| Constant | Path | Description |
|----------|------|-------------|
| `blocks` | `/flatmates/blocks` | List blocked users |
| `block(id)` | `/flatmates/blocks/{id}` | Block/unblock user |

### Conversations

| Constant | Path | Description |
|----------|------|-------------|
| `conversations` | `/flatmates/conversations` | List conversations |
| `conversation(id)` | `/flatmates/conversations/{id}` | Conversation detail |
| `conversationMessages(id)` | `/flatmates/conversations/{id}/messages` | Messages in conversation |
| `conversationMarkRead(id)` | `/flatmates/conversations/{id}/mark-read` | Mark messages as read |
| `conversationQnA(id)` | `/flatmates/conversations/{id}/qna` | Q&A for conversation |

### Swipes & Likes

| Constant | Path | Description |
|----------|------|-------------|
| `swipes` | `/flatmates/swipes` | Submit swipe action |
| `incomingLikes` | `/flatmates/likes` | Users who liked you |
| `outgoingLikes` | `/flatmates/outgoing-likes` | Users you liked |
| `profileViews` | `/flatmates/profile-views` | Profile view history |

### Properties

| Constant | Path | Description |
|----------|------|-------------|
| `properties` | `/properties` | List/search properties |
| `property(id)` | `/properties/{id}` | Property detail |
| `myProperties` | `/properties/me` | Current user's properties |

### Visits

| Constant | Path | Description |
|----------|------|-------------|
| `visits` | `/visits` | List/schedule visits |
| `visit(id)` | `/visits/{id}` | Visit detail |

### Notifications

| Constant | Path | Description |
|----------|------|-------------|
| `notifications` | `/flatmates/notifications` | List notifications |
| `notificationDetail(id)` | `/flatmates/notifications/{id}` | Notification detail |
| `notificationMarkAllRead` | `/flatmates/notifications` | Mark all as read |
| `notificationRegister` | `/notifications/devices/register` | Register FCM token |
| `notificationUnregister` | `/notifications/devices/unregister` | Unregister FCM token |

### Other

| Constant | Path | Description |
|----------|------|-------------|
| `versionCheck` | `/versions/check` | App version check |
| `bugs` | `/bugs` | Submit bug reports |
| `sse` | `/flatmates/sse` | SSE event stream |
| `flatmatesProfile` | `/flatmates/profile` | Flatmates-specific profile |
| `flatmatesProfiles` | `/flatmates/profiles` | Browse profiles |
| `societyTagVotes(id)` | `/flatmates/listings/{id}/society-tags/votes` | Society tag voting |

## App constants

**File:** `lib/core/config/constants.dart`

| Constant | Value |
|----------|-------|
| `kPrivacyPolicyUrl` | `https://360ghar.com/policies/privacy-policy` |
| `kTermsOfServiceUrl` | `https://360ghar.com/policies/terms-of-service` |
| `kSupportEmail` | `info@360ghar.com` |
| `kAppStoreId` | Build-time `--dart-define` |
| `kPlayStoreId` | `com.the360ghar.flatmates360` |
| `appStoreUrl` | `https://apps.apple.com/app/id{kAppStoreId}` |
| `playStoreUrl` | `https://play.google.com/store/apps/details?id={kPlayStoreId}` |
