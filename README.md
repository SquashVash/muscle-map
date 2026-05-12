# muscle_map

A Flutter package for displaying an interactive human body muscle map. Supports tap-to-select muscles and intensity-based heat map visualization.

> **Fork of [muscle_selector](https://github.com/EmilCes/muscle_selector) by EmilCes.** This package extends the original with intensity mapping, additional muscle groups, and bug fixes.

---

## Features

- Interactive SVG-based human body diagrams (full body, front only, back only)
- **`MusclePickerMap`** — tap muscles to select/deselect them; get a callback with the selected set
- **`MuscleIntensityMap`** — display muscles colored by workout intensity (light / medium / hard)
- Group-aware selection — tapping one part of a muscle group selects the whole group
- Toggle mode — tap once to select, tap again to deselect
- Pre-select muscles programmatically on load
- Customizable stroke color, selected color, and dot color

---

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  muscle_map: ^1.0.5
```

Then run:

```sh
flutter pub get
```

---

## Usage

### MusclePickerMap

Lets users tap muscles to select them. Returns a `Set<Muscle>` on every change.

```dart
import 'package:muscle_map/muscle_map.dart';

MusclePickerMap(
  map: Maps.BODY,           // Maps.BODY | Maps.FRONT_BODY | Maps.BACK_BODY
  onChanged: (muscles) {
    print(muscles);         // Set<Muscle>
  },
  strokeColor: Colors.black,
  selectedColor: Colors.blue,
  actAsToggle: true,        // tap again to deselect
  initialSelectedGroups: ['chest', 'biceps'],
)
```

To clear the selection programmatically, pass a `GlobalKey` and call `clearSelect()`:

```dart
final GlobalKey<MusclePickerMapState> _mapKey = GlobalKey();

MusclePickerMap(key: _mapKey, ...)

// later:
_mapKey.currentState?.clearSelect();
```

---

### MuscleIntensityMap

Displays muscles colored by intensity level. Pass an `initialSelectedGroups` map of group name → `MuscleIntensity`.

```dart
MuscleIntensityMap(
  map: Maps.BODY,
  initialSelectedGroups: {
    'chest':     MuscleIntensity.light,
    'biceps':    MuscleIntensity.hard,
    'triceps':   MuscleIntensity.hard,
    'shoulders': MuscleIntensity.medium,
  },
  onChanged: (muscles) {},
  strokeColor: Colors.black,
)
```

Intensity color scale:

| Intensity | Color |
|-----------|-------|
| `none` | Grey |
| `light` | Amber |
| `medium` | Orange |
| `hard` | Red |

---

## Available Maps

| Constant | Description |
|----------|-------------|
| `Maps.BODY` | Full body (front + back) |
| `Maps.FRONT_BODY` | Front view only |
| `Maps.BACK_BODY` | Back view only |

---

## Muscle Groups

The following group keys can be used with `initialSelectedGroups`:

`chest`, `shoulders`, `obliques`, `abs`, `abductor`, `biceps`, `calves`, `forearm`, `glutes`, `harmstrings`, `lats`, `upper_back`, `quads`, `trapezius`, `triceps`, `adductors`, `lower_back`, `neck`

---

## Widget Parameters

### MusclePickerMap

| Parameter | Type | Description |
|-----------|------|-------------|
| `map` | `String` | Map asset to display (`Maps.*`) |
| `onChanged` | `Function(Set<Muscle>)` | Called on every selection change |
| `initialSelectedMuscles` | `Set<Muscle>?` | Pre-selected muscles |
| `initialSelectedGroups` | `List<String>?` | Pre-selected muscle groups by name |
| `actAsToggle` | `bool?` | If true, tapping a selected muscle deselects it |
| `isEditing` | `bool?` | Disables tap interaction when true |
| `strokeColor` | `Color?` | Outline color of muscle paths |
| `selectedColor` | `Color?` | Fill color of selected muscles |
| `dotColor` | `Color?` | Dot/accent color |
| `width` / `height` | `double?` | Widget dimensions |

### MuscleIntensityMap

| Parameter | Type | Description |
|-----------|------|-------------|
| `map` | `String` | Map asset to display (`Maps.*`) |
| `onChanged` | `Function(Set<Muscle>)` | Called when muscles are loaded/changed |
| `initialSelectedMuscles` | `Set<Muscle>?` | Pre-selected muscles |
| `initialSelectedGroups` | `Map<String, MuscleIntensity>?` | Group name → intensity |
| `strokeColor` | `Color?` | Outline color of muscle paths |
| `width` / `height` | `double?` | Widget dimensions |

---

## Credits

Forked from [muscle_selector](https://github.com/EmilCes/muscle_selector) by [EmilCes](https://github.com/EmilCes).

## License

See [LICENSE](LICENSE).
