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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
              onBodyMapChanged: (map) => setState(() => _bodyMap = map),
              onPresetChanged: (preset) => setState(() => _preset = preset),
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
  final ValueChanged<String> onBodyMapChanged;
  final ValueChanged<Set<Muscle>> onSelectionChanged;
  final VoidCallback onClear;

  const _SelectTab({
    required this.bodyMap,
    required this.pickerKey,
    required this.selectedMuscles,
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
  final ValueChanged<String> onBodyMapChanged;
  final ValueChanged<String> onPresetChanged;

  const _IntensityTab({
    required this.bodyMap,
    required this.preset,
    required this.presets,
    required this.onBodyMapChanged,
    required this.onPresetChanged,
  });

  static const _legend = [
    ('None', Colors.grey),
    ('Light', Colors.amberAccent),
    ('Medium', Colors.orangeAccent),
    ('Hard', Colors.redAccent),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
            children: _legend.map((entry) {
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
