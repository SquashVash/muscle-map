import 'package:flutter/material.dart';
import 'package:muscle_map/muscle_map.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Muscle Map',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
      ),
      home: const HomeView(),
    );
  }
}

/// Bundles every knob exposed by [MusclePickerMap] / [MuscleIntensityMap]
/// that the Options tab lets the user play with.
class MapOptions {
  final double strokeWidth;
  final StrokeCap strokeCap;
  final StrokeJoin strokeJoin;
  final bool showSkeleton;
  final double skeletonBorderRadius;
  final Duration skeletonAnimationDuration;
  final Color? skeletonColor;
  final bool useCustomIntensityColors;

  const MapOptions({
    this.strokeWidth = 1.0,
    this.strokeCap = StrokeCap.butt,
    this.strokeJoin = StrokeJoin.miter,
    this.showSkeleton = true,
    this.skeletonBorderRadius = 16,
    this.skeletonAnimationDuration = const Duration(milliseconds: 900),
    this.skeletonColor,
    this.useCustomIntensityColors = false,
  });

  MapOptions copyWith({
    double? strokeWidth,
    StrokeCap? strokeCap,
    StrokeJoin? strokeJoin,
    bool? showSkeleton,
    double? skeletonBorderRadius,
    Duration? skeletonAnimationDuration,
    Color? Function()? skeletonColor,
    bool? useCustomIntensityColors,
  }) {
    return MapOptions(
      strokeWidth: strokeWidth ?? this.strokeWidth,
      strokeCap: strokeCap ?? this.strokeCap,
      strokeJoin: strokeJoin ?? this.strokeJoin,
      showSkeleton: showSkeleton ?? this.showSkeleton,
      skeletonBorderRadius: skeletonBorderRadius ?? this.skeletonBorderRadius,
      skeletonAnimationDuration:
          skeletonAnimationDuration ?? this.skeletonAnimationDuration,
      skeletonColor:
          skeletonColor != null ? skeletonColor() : this.skeletonColor,
      useCustomIntensityColors:
          useCustomIntensityColors ?? this.useCustomIntensityColors,
    );
  }
}

Color customIntensityColor(MuscleIntensity intensity) {
  switch (intensity) {
    case MuscleIntensity.none:
      return Colors.blueGrey.shade100;
    case MuscleIntensity.light:
      return Colors.tealAccent;
    case MuscleIntensity.medium:
      return Colors.purpleAccent;
    case MuscleIntensity.hard:
      return Colors.pinkAccent.shade700;
  }
}

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView>
    with SingleTickerProviderStateMixin {
  static const _presets = <String, Map<String, MuscleIntensity>>{
    'Push Day': {
      'chest': MuscleIntensity.hard,
      'shoulders': MuscleIntensity.medium,
      'triceps': MuscleIntensity.medium,
    },
    'Pull Day': {
      'lats': MuscleIntensity.hard,
      'upper_back': MuscleIntensity.medium,
      'biceps': MuscleIntensity.medium,
      'trapezius': MuscleIntensity.light,
    },
    'Leg Day': {
      'quads': MuscleIntensity.hard,
      'harmstrings': MuscleIntensity.hard,
      'glutes': MuscleIntensity.medium,
      'calves': MuscleIntensity.light,
    },
  };

  late final TabController _tabController;
  final _pickerKey = GlobalKey<MusclePickerMapState>();

  String _bodyMap = Maps.BODY;
  Set<Muscle> _selectedMuscles = {};
  String _preset = 'Push Day';
  MapOptions _options = const MapOptions();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Muscle Map'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Select', icon: Icon(Icons.touch_app_outlined)),
            Tab(
                text: 'Intensity',
                icon: Icon(Icons.local_fire_department_outlined)),
            Tab(text: 'Options', icon: Icon(Icons.tune)),
          ],
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            _SelectTab(
              bodyMap: _bodyMap,
              pickerKey: _pickerKey,
              selectedMuscles: _selectedMuscles,
              options: _options,
              onBodyMapChanged: (map) => setState(() => _bodyMap = map),
              onSelectionChanged: (muscles) =>
                  setState(() => _selectedMuscles = muscles),
              onClear: () {
                _pickerKey.currentState?.clearSelect();
                setState(() => _selectedMuscles = {});
              },
            ),
            _IntensityTab(
              bodyMap: _bodyMap,
              preset: _preset,
              presets: _presets,
              options: _options,
              onBodyMapChanged: (map) => setState(() => _bodyMap = map),
              onPresetChanged: (preset) => setState(() => _preset = preset),
            ),
            _OptionsTab(
              options: _options,
              onChanged: (options) => setState(() => _options = options),
            ),
          ],
        ),
      ),
    );
  }
}

class _BodyMapSwitcher extends StatelessWidget {
  final String bodyMap;
  final ValueChanged<String> onChanged;

  const _BodyMapSwitcher({required this.bodyMap, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SegmentedButton<String>(
        segments: const [
          ButtonSegment(
            value: Maps.BODY,
            label: Text('Full'),
            icon: Icon(Icons.accessibility_new),
          ),
          ButtonSegment(value: Maps.FRONT_BODY, label: Text('Front')),
          ButtonSegment(value: Maps.BACK_BODY, label: Text('Back')),
        ],
        selected: {bodyMap},
        onSelectionChanged: (selection) => onChanged(selection.first),
      ),
    );
  }
}

class _SelectTab extends StatelessWidget {
  final String bodyMap;
  final GlobalKey<MusclePickerMapState> pickerKey;
  final Set<Muscle> selectedMuscles;
  final MapOptions options;
  final ValueChanged<String> onBodyMapChanged;
  final ValueChanged<Set<Muscle>> onSelectionChanged;
  final VoidCallback onClear;

  const _SelectTab({
    required this.bodyMap,
    required this.pickerKey,
    required this.selectedMuscles,
    required this.options,
    required this.onBodyMapChanged,
    required this.onSelectionChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titles = selectedMuscles.map((m) => m.title).toSet().toList()
      ..sort();

    return Column(
      children: [
        _BodyMapSwitcher(bodyMap: bodyMap, onChanged: onBodyMapChanged),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: MusclePickerMap(
              key: pickerKey,
              map: bodyMap,
              actAsToggle: true,
              strokeColor: theme.colorScheme.outline,
              selectedColor: theme.colorScheme.primary,
              onChanged: onSelectionChanged,
              strokeWidth: options.strokeWidth,
              strokeCap: options.strokeCap,
              strokeJoin: options.strokeJoin,
              showSkeleton: options.showSkeleton,
              skeletonColor: options.skeletonColor,
              skeletonBorderRadius: options.skeletonBorderRadius,
              skeletonAnimationDuration: options.skeletonAnimationDuration,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHigh,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text('Selected muscles', style: theme.textTheme.titleSmall),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: titles.isEmpty ? null : onClear,
                    icon: const Icon(Icons.clear_all, size: 18),
                    label: const Text('Clear'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (titles.isEmpty)
                Text(
                  'Tap a muscle on the map to select it.',
                  style: theme.textTheme.bodySmall,
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: titles.map((t) => Chip(label: Text(t))).toList(),
                ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ],
    );
  }
}

class _IntensityTab extends StatelessWidget {
  final String bodyMap;
  final String preset;
  final Map<String, Map<String, MuscleIntensity>> presets;
  final MapOptions options;
  final ValueChanged<String> onBodyMapChanged;
  final ValueChanged<String> onPresetChanged;

  const _IntensityTab({
    required this.bodyMap,
    required this.preset,
    required this.presets,
    required this.options,
    required this.onBodyMapChanged,
    required this.onPresetChanged,
  });

  static const _defaultLegend = [
    ('None', Colors.grey),
    ('Light', Colors.amberAccent),
    ('Medium', Colors.orangeAccent),
    ('Hard', Colors.redAccent),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final legend = options.useCustomIntensityColors
        ? [
            ('None', customIntensityColor(MuscleIntensity.none)),
            ('Light', customIntensityColor(MuscleIntensity.light)),
            ('Medium', customIntensityColor(MuscleIntensity.medium)),
            ('Hard', customIntensityColor(MuscleIntensity.hard)),
          ]
        : _defaultLegend;

    return Column(
      children: [
        _BodyMapSwitcher(bodyMap: bodyMap, onChanged: onBodyMapChanged),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 8,
            children: presets.keys.map((name) {
              return ChoiceChip(
                label: Text(name),
                selected: preset == name,
                onSelected: (_) => onPresetChanged(name),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: MuscleIntensityMap(
              map: bodyMap,
              initialSelectedGroups: presets[preset]!,
              strokeColor: theme.colorScheme.outline,
              onChanged: (_) {},
              intensityColorBuilder:
                  options.useCustomIntensityColors ? customIntensityColor : null,
              strokeWidth: options.strokeWidth,
              strokeCap: options.strokeCap,
              strokeJoin: options.strokeJoin,
              showSkeleton: options.showSkeleton,
              skeletonColor: options.skeletonColor,
              skeletonBorderRadius: options.skeletonBorderRadius,
              skeletonAnimationDuration: options.skeletonAnimationDuration,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHigh,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Wrap(
            spacing: 16,
            runSpacing: 8,
            children: legend.map((entry) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: entry.$2,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(entry.$1, style: theme.textTheme.bodySmall),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

const _skeletonColorChoices = <String, Color?>{
  'Default': null,
  'Blue': Colors.blueAccent,
  'Purple': Colors.deepPurpleAccent,
  'Green': Colors.greenAccent,
};

class _OptionsTab extends StatelessWidget {
  final MapOptions options;
  final ValueChanged<MapOptions> onChanged;

  const _OptionsTab({required this.options, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentSkeletonColorLabel = _skeletonColorChoices.entries
        .firstWhere((e) => e.value == options.skeletonColor,
            orElse: () => _skeletonColorChoices.entries.first)
        .key;

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      children: [
        Text('Stroke', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Text('Width: ${options.strokeWidth.toStringAsFixed(1)}',
            style: theme.textTheme.bodySmall),
        Slider(
          value: options.strokeWidth,
          min: 0.5,
          max: 6,
          divisions: 11,
          label: options.strokeWidth.toStringAsFixed(1),
          onChanged: (value) =>
              onChanged(options.copyWith(strokeWidth: value)),
        ),
        const SizedBox(height: 8),
        Text('Cap', style: theme.textTheme.bodySmall),
        const SizedBox(height: 4),
        SegmentedButton<StrokeCap>(
          segments: const [
            ButtonSegment(value: StrokeCap.butt, label: Text('Butt')),
            ButtonSegment(value: StrokeCap.round, label: Text('Round')),
            ButtonSegment(value: StrokeCap.square, label: Text('Square')),
          ],
          selected: {options.strokeCap},
          onSelectionChanged: (selection) =>
              onChanged(options.copyWith(strokeCap: selection.first)),
        ),
        const SizedBox(height: 12),
        Text('Join', style: theme.textTheme.bodySmall),
        const SizedBox(height: 4),
        SegmentedButton<StrokeJoin>(
          segments: const [
            ButtonSegment(value: StrokeJoin.miter, label: Text('Miter')),
            ButtonSegment(value: StrokeJoin.round, label: Text('Round')),
            ButtonSegment(value: StrokeJoin.bevel, label: Text('Bevel')),
          ],
          selected: {options.strokeJoin},
          onSelectionChanged: (selection) =>
              onChanged(options.copyWith(strokeJoin: selection.first)),
        ),
        const Divider(height: 32),
        Text('Loading skeleton', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Show skeleton while loading'),
          value: options.showSkeleton,
          onChanged: (value) =>
              onChanged(options.copyWith(showSkeleton: value)),
        ),
        if (options.showSkeleton) ...[
          const SizedBox(height: 4),
          Text('Color', style: theme.textTheme.bodySmall),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            children: _skeletonColorChoices.keys.map((label) {
              return ChoiceChip(
                label: Text(label),
                selected: currentSkeletonColorLabel == label,
                onSelected: (_) => onChanged(options.copyWith(
                    skeletonColor: () => _skeletonColorChoices[label])),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          Text(
              'Border radius: ${options.skeletonBorderRadius.toStringAsFixed(0)}',
              style: theme.textTheme.bodySmall),
          Slider(
            value: options.skeletonBorderRadius,
            min: 0,
            max: 40,
            divisions: 8,
            label: options.skeletonBorderRadius.toStringAsFixed(0),
            onChanged: (value) =>
                onChanged(options.copyWith(skeletonBorderRadius: value)),
          ),
          Text(
              'Animation speed: ${options.skeletonAnimationDuration.inMilliseconds}ms',
              style: theme.textTheme.bodySmall),
          Slider(
            value: options.skeletonAnimationDuration.inMilliseconds
                .toDouble(),
            min: 200,
            max: 2000,
            divisions: 9,
            label: '${options.skeletonAnimationDuration.inMilliseconds}ms',
            onChanged: (value) => onChanged(options.copyWith(
                skeletonAnimationDuration:
                    Duration(milliseconds: value.round()))),
          ),
        ],
        const Divider(height: 32),
        Text('Intensity colors', style: theme.textTheme.titleMedium),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Use custom intensity color scheme'),
          subtitle: const Text('Overrides the default grey/amber/orange/red'),
          value: options.useCustomIntensityColors,
          onChanged: (value) =>
              onChanged(options.copyWith(useCustomIntensityColors: value)),
        ),
      ],
    );
  }
}
