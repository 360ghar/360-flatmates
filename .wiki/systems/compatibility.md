# Compatibility

The compatibility system computes a match percentage between two users based on 6 lifestyle dimensions. It runs entirely client-side in `lib/core/compatibility/` and renders the result as an animated ring widget.

## Key abstractions

### CompatibilityEngine

**File:** `lib/core/compatibility/compatibility_engine.dart`

A stateless calculator with a single static entry point:

```dart
CompatibilityResult calculate({
  required Map<String, String> user,
  required Map<String, String> peer,
})
```

It evaluates 6 dimensions, computes a weighted percentage, and returns the top 3 matching chips for display.

### The 6 dimensions

| Dimension | Key | Weight | Values | Scoring |
|-----------|-----|--------|--------|---------|
| **Sleep Schedule** | `sleep_schedule` | 0.20 | `early_bird`, `flexible`, `night_owl` | Same=100, adjacent=50, opposite=0 |
| **Cleanliness** | `cleanliness` | 0.20 | `minimal`, `tidy`, `spotless` | Same=100, 1-step=50, 2-step=0 |
| **Food Habits** | `food_habits` | 0.15 | `vegetarian`, `vegan`, `non_vegetarian`, `no_preference` | Same=100, both strict=100, one strict+one not=0, no_preference=100 |
| **Smoking/Drinking** | `smoking_drinking` | 0.20 | `neither`, `drink_occasionally`, `smoke_outside`, `both_fine`, `no_preference` | Complex: same=100, both non-smoker=80, smoker+non-smoker=30, both drinker=80, no_preference=100 |
| **Guests Policy** | `guests_policy` | 0.15 | `no_overnight_guests`, `occasional_ok`, `open_house` | Same=100, 1-step=60, 2-step=20 |
| **Work Style** | `work_style` | 0.10 | `wfh`, `office`, `hybrid` | Same=100, wfh+office=40, hybrid+other=70 |

**Weighted calculation:**
```text
percentage = (sum of dimension.score * dimension.weight) / (sum of weights) * 100
```

**Color thresholds:**
- >= 70% -- green (`AppSemanticColors.compatHigh` / `#5B8C44`)
- 40-69% -- amber (`AppSemanticColors.compatMedium` / `#B57828`)
- < 40% -- red (`AppSemanticColors.compatLow` / `#B4452C`)

**Value normalization:** The engine normalizes backend values (e.g., `veg` to `vegetarian`, `non_veg` to `non_vegetarian`, `no` to `neither`, `yes` to `smoke_outside`).

### CompatibilityResult

The return type containing:
- `percentage` -- the overall match score (0-100)
- `dimensions` -- all 6 `CompatibilityDimension` objects (with key, weight, user/peer values, score, isMatch, summary)
- `topMatchChips` -- up to 3 summary strings from the highest-scoring matching dimensions (e.g., "Sleep habits", "Food preferences")

### CompatibilityRing

**File:** `lib/core/compatibility/compatibility_ring.dart`

A `ConsumerStatefulWidget` that renders an animated circular progress ring:

- Uses `CustomPaint` with `_ArcPainter` for the arc drawing
- Animates from 0 to the target percentage over 300ms (ease-out)
- Color is determined by the score threshold (green/amber/red)
- When `percentage` is 0 (no reliable score), shows "New" label instead of a number
- Re-animates when `percentage` changes via `didUpdateWidget`

Default size: 72px, stroke width: 5px.

### CompatibilityBreakdown

A `StatelessWidget` that renders all 6 dimensions as a vertical list with check/warning icons, summary text, and percentage scores. Used in flat details and profile views.

## How it works

1. The backend returns `user_preferences` and `peer_preferences` as `Map<String, String>` in the bootstrap/profile data
2. The controller or widget calls `CompatibilityEngine.calculate(user:, peer:)`
3. The engine evaluates each dimension, computes weighted scores, and returns a `CompatibilityResult`
4. The `CompatibilityRing` widget displays the percentage with an animated arc
5. The `CompatibilityBreakdown` widget shows the per-dimension details

## Integration points

- **Bootstrap/profile data** -- user and peer preference maps come from the backend
- **Discover feed** -- listing cards show `CompatibilityRing` for each property owner
- **Swipe deck** -- swipe cards show compatibility scores
- **Flat details** -- shows `CompatibilityBreakdown` for the property owner
- **Profile grid** -- `ProfileGridCard` shows the ring in the top-right corner of the photo

## Key source files

| File | Purpose |
|------|---------|
| `lib/core/compatibility/compatibility_engine.dart` | 6-dimension scoring algorithm |
| `lib/core/compatibility/compatibility_ring.dart` | Animated ring + breakdown widgets |
