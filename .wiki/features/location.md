# Location Feature

**Active contributors:** Saksham Mittal, Ravi Sahu

## Purpose

The location feature provides city/area selection through a location picker modal, a full-screen location search page, and GPS-based current location detection. It integrates Google Places and Nominatim for place suggestions and supports a radius-based search filter.

## Directory Layout

```
lib/features/location/
├── application/
│   ├── location_controller.dart       # GPS + IP location detection
│   └── location_search_provider.dart  # Google Places + Nominatim search
└── presentation/
    ├── location_picker_modal.dart     # Bottom sheet location picker
    ├── location_picker_rows.dart      # Reusable row widgets
    └── map_widgets.dart               # Map-related UI widgets

lib/features/location_search/
└── location_search_page.dart          # Full-screen location search
```

## Key Abstractions

- **`LocationData`** -- simple value object with `name`, `latitude`, and `longitude`.
- **`LocationState`** -- state class for `LocationController` holding current position, address, loading state, error, and selected location.
- **`LocationController`** -- `Notifier<LocationState>` that handles GPS detection, IP fallback, reverse geocoding, and place resolution.
- **`LocationSearchState`** -- state class for `LocationSearchNotifier` holding suggestions and loading state.
- **`LocationSearchNotifier`** -- `Notifier<LocationSearchState>` that debounces search queries and merges results from Google Places and Nominatim.
- **`PlaceSuggestion`** -- suggestion model with `mainText`, `secondaryText`, `placeId`, and `source` (Google Places or Nominatim).

## How It Works

### Location Detection

`LocationController.getCurrentLocation()` follows a cascading strategy:

1. **GPS** -- checks if location services are enabled, requests permission, calls `Geolocator.getCurrentPosition()` with low accuracy
2. **Reverse geocoding** -- converts coordinates to a human-readable address via `placemarkFromCoordinates()`
3. **IP fallback** -- if GPS fails (service disabled, permission denied, timeout), falls back to `ipapi.co/json/` for approximate location
4. **Error handling** -- failures are captured in `LocationState.error`; the UI layer (`LocationPickerModal._useCurrentLocation()`) translates those failures into snackbars and permission action buttons (open settings, grant permission)

### Location Search

`LocationSearchNotifier.onSearchChanged()` implements a 500ms debounce:

1. Queries Google Places Autocomplete API via `GooglePlacesService.getPlaceSuggestions()`
2. Queries Nominatim (OpenStreetMap) via `NominatimService.search()`
3. Merges results, deduplicating by `mainText|secondaryText` key
4. Tracks a `_searchVersion` counter to discard stale results

### Place Resolution

When a suggestion is tapped, `resolveSuggestion()` dispatches based on source:

- **Google Places** -- calls `GooglePlacesService.getPlaceDetails()` with the `placeId`
- **Nominatim** -- calls `NominatimService.getDetails()` with the suggestion

Both return a `PlaceDetails` with `latitude`, `longitude`, and `name`.

### Location Picker Modal

`LocationPickerModal` is a frosted-glass bottom sheet (80% screen height) with:

1. **Search bar** -- debounced search with clear button
2. **Current location button** -- GPS icon that triggers `_useCurrentLocation()`
3. **Radius slider** -- 5-50 km range with 9 divisions, displayed as "N km"
4. **Suggestions list** -- Google Places + Nominatim results as tappable tiles
5. **Popular cities** -- catalog-driven list from `flatmates_popular_cities`, filtered by search query. Cities marked `comingSoon` are displayed with reduced opacity and a "Coming Soon" badge.

When a suggestion is resolved, the modal checks if it matches a catalog city (within `kMaxMatchDistanceKm` via haversine distance) and uses the canonical city name if so.

### Location Search Page

`LocationSearchPage` is a full-screen alternative to the modal, used when a dedicated search experience is needed. It includes:

- Back navigation header
- Search bar with autofocus
- "Use my current location" row with terracotta accent
- Suggestions list as `FlatmatesCard` items
- Loading and empty states

### Location Persistence

`LocationController.selectAndPersistLocation()` saves the selected city to the user's profile via `ProfileRepository.updateProfile()` and refreshes the bootstrap data.

## Integration Points

- **Bootstrap** -- popular cities are fetched from `/flatmates/bootstrap` catalog options (`flatmates_popular_cities`). Each city has `latitude`, `longitude`, and `state` in its metadata.
- **Google Places** -- `GooglePlacesService` in `core/location/google_places_service.dart` wraps the Google Places Autocomplete and Details APIs.
- **Nominatim** -- `NominatimService` in `core/location/nominatim_service.dart` provides OpenStreetMap-based search as a fallback/complement to Google Places.
- **Geolocator** -- uses the `geolocator` package for GPS detection and permission handling.
- **Geocoding** -- uses the `geocoding` package for reverse geocoding coordinates to addresses.
- **Discover Feed** -- the selected location filters the discover feed results.
- **Profile** -- the user's city is part of their profile and is updated when they change location.

## Key Source Files

| File | Purpose |
|------|---------|
| `lib/features/location/application/location_controller.dart` | GPS/IP detection, reverse geocoding, place resolution |
| `lib/features/location/application/location_search_provider.dart` | Debounced search merging Google Places + Nominatim |
| `lib/features/location/presentation/location_picker_modal.dart` | Frosted-glass bottom sheet with search, radius, and cities |
| `lib/features/location/presentation/location_picker_rows.dart` | Reusable row widgets for location picker |
| `lib/features/location/presentation/map_widgets.dart` | Map-related UI widgets |
| `lib/features/location_search/location_search_page.dart` | Full-screen location search page |
| `lib/core/location/google_places_service.dart` | Google Places API wrapper |
| `lib/core/location/nominatim_service.dart` | Nominatim (OpenStreetMap) API wrapper |
| `lib/core/location/location_data.dart` | LocationData value object |
| `lib/core/location/location_helpers.dart` | Location detection helpers |
| `lib/core/location/place_suggestion.dart` | PlaceSuggestion and PlaceDetails models |
