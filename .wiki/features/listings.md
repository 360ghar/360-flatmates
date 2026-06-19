# Listings Feature

**Active contributors:** Saksham Mittal, Ravi Sahu

## Purpose

The listings feature enables room posters to create, edit, publish, and manage property listings. It includes an 8-step listing wizard with draft persistence, photo/video upload, a review flow, and a management hub for active, draft, and expired listings.

## Directory Layout

```text
lib/features/listings/
├── create_listing_page.dart           # 8-step listing wizard
├── listing_under_review_page.dart     # Post-submission review status
├── manage_listing_page.dart           # Manage active/draft/expired listings
├── post_hub_page.dart                 # Landing page for Post tab
├── listings_repository.dart           # API client for CRUD operations
├── domain/
│   └── listing_status.dart            # Status classification helpers
└── presentation/widgets/
    ├── listing_form_data.dart         # Form data aggregation
    ├── listing_step_header.dart       # Step progress header
    ├── listing_step_view.dart         # Per-step form rendering
    └── manage_listing_card.dart       # Listing card for manage view
```

## Key Abstractions

- **`ListingCreateRequest`** -- serializable payload for creating/updating listings via `POST /api/v1/flatmates/properties` and `PUT /api/v1/flatmates/properties/{id}`.
- **`ListingFormData`** -- aggregates all form controllers and sets into a single object that can compute step summaries, validation, and produce a `ListingCreateRequest`.
- **`ListingStepCallbacks`** -- typed callback bundle passed to each step view, decoupling the step UI from page-level state management.
- **`ListingsRepository`** -- Riverpod provider wrapping Dio calls for create, update, fetch-my-listings, and toggle-pause operations.

## How It Works

### 8-Step Listing Wizard

`CreateListingPage` is a `ConsumerStatefulWidget` that manages an 8-step flow:

1. **Society** -- society name, type (gated/independent), amenities, vibe tags
2. **Room** -- room type (private/shared), furnishing, features, photo upload, video tour URL
3. **Flat Config** -- flat configuration (BHK), floor, total floors, flat amenities
4. **Costs** -- rent, deposit, maintenance, electricity inclusion, cook/maid/setup costs
5. **Preferences** -- gender preference, age range, non-negotiables
6. **Availability** -- available-from date picker
7. **Typical Day** -- description of a typical day in the flat
8. **Review & Publish** -- summary of all steps before submission

Each step uses `ListingStepView` which renders the appropriate form fields. Navigation is controlled by `_step` state with inline validation via `computeStepValidation()`. The form tracks `_dirty` state and shows a discard confirmation dialog when the user backs out mid-flow.

### Photo & Video Upload

Photos are uploaded via `ImageUploadService` which delegates to Cloudinary through the backend API. The wizard supports up to 10 room photos. Video tours are stored as URLs and included in `listing_preferences.video_tour_url`.

### Edit Mode

When `listingId` is passed to `CreateListingPage`, it loads the existing listing via `DiscoverRepository.fetchListing()` and populates all form controllers. Submission calls `updateListing()` instead of `createListing()`.

### Under Review Page

After submission, the user is routed to `/listing-review/{id}` which renders `ListingUnderReviewPage`. This page:

- Fetches the listing and displays its current status
- Listens for SSE `listing_status_changed` events to auto-refresh
- Shows a progress indicator (Submitted -> Under Review -> Live)
- Displays a rejection reason card if the listing was rejected
- Provides CTAs to edit/resubmit or go to home feed

### Post Hub

`PostHubPage` is the landing page for the Post tab (room poster mode). It shows two hub cards: "Post a New Listing" and "Manage Listings" with active/draft counts.

### Manage Listings

`ManageListingPage` uses a `FlatmatesSegmentedControl` to filter between active, draft, and expired listings. Each listing card supports:

- **Pause/Resume** -- toggles `moderation_status` between `live` and `paused`
- **Share** -- generates a deep link via `DeepLinkService.listingUrl()`
- **Copy Link** -- copies the deep link to clipboard
- **Edit** -- navigates to the wizard in edit mode
- **View Stats** -- bottom sheet showing views, likes, and matches
- **Review** -- navigates to the under-review page
- **Renew** -- re-opens the wizard for renewal

## Integration Points

- **Bootstrap** -- catalog options for society amenities, vibe tags, room features, furnishing, and flat config are fetched from `/flatmates/bootstrap` and resolved via `CatalogHelpers`.
- **Discover Feed** -- after successful create/update, `DiscoverFeedController.refresh()` is called and `myListingsProvider` is invalidated.
- **SSE** -- the under-review page subscribes to `sseEventProvider` for real-time status updates.
- **Deep Links** -- listing URLs use the format `/flatmates/listing/{id}` for sharing.

## Key Source Files

| File | Purpose |
|------|---------|
| `lib/features/listings/create_listing_page.dart` | 8-step listing wizard with edit mode |
| `lib/features/listings/listings_repository.dart` | API client for listing CRUD and toggle-pause |
| `lib/features/listings/listing_under_review_page.dart` | Post-submission review status with SSE |
| `lib/features/listings/manage_listing_page.dart` | Manage active/draft/expired listings |
| `lib/features/listings/post_hub_page.dart` | Landing page for Post tab |
| `lib/features/listings/presentation/widgets/listing_form_data.dart` | Form data aggregation and validation |
| `lib/core/config/endpoints.dart` | API path constants (`FlatmatesEndpoints`) |
| `lib/core/storage/image_upload_service.dart` | Photo/video upload via Cloudinary |
