## 1.0.0

- Muscle Selector for Flutter

## 1.0.1
- Bug fix for muscle deselection.

## 1.0.2
- Now widget accepts a list of initial group of muscles

## 1.0.3
- Neck and Lower Back Implementation

## 1.0.4
- Fix spelling of 'hamstrings', correct 'lats' mapping and add 'upper back'

## 1.0.5
- Forked from `muscle_selector` and renamed the package to `muscle_map`
- Added `MuscleIntensityMap` for intensity-based (heat map) muscle visualization
- Added front-only and back-only body diagrams (`Maps.FRONT_BODY`, `Maps.BACK_BODY`) alongside the full-body map

## 1.0.6
- Show a pulsing loading skeleton instead of a blank area while a map is being parsed
- Cache parsed maps and preload the bundled maps in the background, so switching between maps is instant after the first load
- Crossfade between map states by default (configurable via `enableCrossfade` and `crossfadeDuration`), while plain instant switching remains available
- Fix `MuscleIntensityMap` not refreshing when `initialSelectedGroups` or `initialSelectedMuscles` changes without the `map` itself changing
- Rebuild the example app as a two-tab showcase of `MusclePickerMap` and `MuscleIntensityMap`