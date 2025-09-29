import 'package:flutter/material.dart';
import 'package:muscle_selector/muscle_selector.dart';
import 'package:muscle_selector/src/widgets/muscle_painter.dart';
import '../models/MuscleIntensity.dart';
import '../parser.dart';
import '../size_controller.dart';

class MuscleIntensityMap extends StatefulWidget {
  final double? width;
  final double? height;
  final String map;
  final Function(Set<Muscle> muscles) onChanged;
  final Color? strokeColor;
  final Set<Muscle>? initialSelectedMuscles;
  final Map<String, MuscleIntensity>? initialSelectedGroups;

  const MuscleIntensityMap({
    Key? key,
    required this.map,
    required this.onChanged,
    this.width,
    this.height,
    this.strokeColor,
    this.initialSelectedMuscles,
    this.initialSelectedGroups
  }) : super(key: key);

  @override
  MuscleIntensityMapState createState() => MuscleIntensityMapState();
}

class MuscleIntensityMapState extends State<MuscleIntensityMap> {
  final List<Muscle> _muscleList = [];
  final Set<Muscle> selectedMuscles = {};

  final _sizeController = SizeController.instance;
  Size? mapSize;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMuscleList();
    });
  }

  @override
  void didUpdateWidget(covariant MuscleIntensityMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.map != widget.map) {
      selectedMuscles.clear();
      _loadMuscleList();
    }
  }

  _loadMuscleList() async {
    final list = await Parser.instance.svgToMuscleList(widget.map);
    _muscleList.clear();
    setState(() {
      _muscleList.addAll(list);
      mapSize = _sizeController.mapSize;
      _initializeSelectedMuscles();
    });
  }

  void _initializeSelectedMuscles() {
    if (widget.initialSelectedMuscles != null) {
      selectedMuscles.addAll(widget.initialSelectedMuscles!);
    } else if (widget.initialSelectedGroups != null && widget.initialSelectedGroups!.isNotEmpty) {
      final groupMuscles = Parser.instance.getMusclesByGroupsWithIntensity(widget.initialSelectedGroups!, _muscleList);
      selectedMuscles.addAll(groupMuscles);
    }
    widget.onChanged.call(selectedMuscles);
  }

  void clearSelect() {
    setState(() {
      selectedMuscles.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        for (var muscle in _muscleList) _buildStackItem(muscle),
      ],
    );
  }

  Widget _buildStackItem(Muscle muscle) {
    return GestureDetector(
      behavior: HitTestBehavior.deferToChild,
      child: CustomPaint(
        isComplex: true,
        foregroundPainter: MusclePainter(
          muscle: muscle,
          selectedMuscles: selectedMuscles,
          dotColor: getMuscleColor(muscle),
          selectedColor: getMuscleColor(muscle),
          strokeColor: widget.strokeColor,
        ),
        child: Container(
          width: widget.width ?? double.infinity,
          height: widget.height ?? double.infinity,
          constraints: BoxConstraints(
            maxWidth: mapSize?.width ?? 0,
            maxHeight: mapSize?.height ?? 0,
          ),
          alignment: Alignment.center,
        ),
      ),
    );
  }

  Color getMuscleColor(Muscle muscle){
      switch(muscle.intensity){
        case MuscleIntensity.none:
          return Colors.grey;
        case MuscleIntensity.light:
          return Colors.amberAccent;
        case MuscleIntensity.medium:
          return Colors.orangeAccent;
        case MuscleIntensity.hard:
          return Colors.redAccent;
      }
  }
}
