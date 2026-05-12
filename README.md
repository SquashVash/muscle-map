# muscle_map

A Flutter package for displaying an interactive human body muscle map. Supports tap-to-select muscles and intensity-based heat map visualization.

> **Fork of [muscle_selector](https://github.com/EmilCes/muscle_selector) by EmilCes.** This package extends the original with intensity mapping, additional muscle groups, and bug fixes.

---

## Features

- Interactive SVG-based human body diagrams (full body, front only, back only)
- **`MusclePickerMap`** — tap muscles to select/deselect them; get a callback with the selected set
- **`MuscleIntensityMap`** — display muscles colored by workout intensity (light / medium / hard)

---

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  muscle_map: any
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

## Muscle Groups

The following group keys can be used with `initialSelectedGroups`:

`chest`, `shoulders`, `obliques`, `abs`, `abductor`, `biceps`, `calves`, `forearm`, `glutes`, `harmstrings`, `lats`, `upper_back`, `quads`, `trapezius`, `triceps`, `adductors`, `lower_back`, `neck`

---

## Credits

Forked from [muscle_selector](https://github.com/EmilCes/muscle_selector) by [EmilCes](https://github.com/EmilCes).

## License

See [LICENSE](LICENSE).
