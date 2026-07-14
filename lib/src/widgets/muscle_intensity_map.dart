import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:muscle_map/muscle_map.dart';
import 'package:muscle_map/src/widgets/muscle_painter.dart';
import 'package:muscle_map/src/widgets/muscle_map_skeleton.dart';
import '../colors.dart' as intensity_colors;
import '../parser.dart';
import '../size_controller.dart';

const _mapEquality = MapEquality<String, MuscleIntensity>();
const _setEquality = SetEquality<Muscle>();

class MuscleIntensityMap extends StatefulWidget {
  final double? width;
  final double? height;
  final String map;
  final Function(Set<Muscle> muscles) onChanged;
  final Color? strokeColor;
  final Set<Muscle>? initialSelectedMuscles;
  final Map<String, MuscleIntensity>? initialSelectedGroups;
  final bool enableCrossfade;
  final Duration crossfadeDuration;
  final Color Function(MuscleIntensity intensity)? intensityColorBuilder;
  final double strokeWidth;
  final StrokeCap? strokeCap;
  final StrokeJoin? strokeJoin;
  final bool showSkeleton;
  final WidgetBuilder? loadingBuilder;
  final Color? skeletonColor;
  final Duration skeletonAnimationDuration;
  final double skeletonOpacityBegin;
  final double skeletonOpacityEnd;
  final Curve skeletonCurve;
  final double skeletonBorderRadius;

  const MuscleIntensityMap({
    Key? key,
    required this.map,
    required this.onChanged,
    this.width,
    this.height,
    this.strokeColor,
    this.initialSelectedMuscles,
    this.initialSelectedGroups,
    this.enableCrossfade = true,
    this.crossfadeDuration = const Duration(milliseconds: 100),
    this.intensityColorBuilder,
    this.strokeWidth = 1.0,
    this.strokeCap,
    this.strokeJoin,
    this.showSkeleton = true,
    this.loadingBuilder,
    this.skeletonColor,
    this.skeletonAnimationDuration = const Duration(milliseconds: 900),
    this.skeletonOpacityBegin = 0.4,
    this.skeletonOpacityEnd = 1.0,
    this.skeletonCurve = Curves.easeInOut,
    this.skeletonBorderRadius = 16,
  }) : super(key: key);

  @override
  MuscleIntensityMapState createState() => MuscleIntensityMapState();
}

class MuscleIntensityMapState extends State<MuscleIntensityMap> {
  final List<Muscle> _muscleList = [];
  final Set<Muscle> selectedMuscles = {};

  final _sizeController = SizeController.instance;
  Size? mapSize;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    unawaited(Parser.instance.preloadBundledMaps());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMuscleList();
    });
  }

  @override
  void didUpdateWidget(covariant MuscleIntensityMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.map != widget.map) {
      setState(() {
        selectedMuscles.clear();
        _isLoading = true;
      });
      _loadMuscleList();
    } else if (!_selectionEquals(oldWidget, widget)) {
      setState(() {
        for (final muscle in _muscleList) {
          muscle.intensity = MuscleIntensity.none;
        }
        selectedMuscles.clear();
        _initializeSelectedMuscles();
      });
    }
  }

  bool _selectionEquals(MuscleIntensityMap a, MuscleIntensityMap b) {
    return _setEquality.equals(a.initialSelectedMuscles, b.initialSelectedMuscles) &&
        _mapEquality.equals(a.initialSelectedGroups, b.initialSelectedGroups);
  }

  _loadMuscleList() async {
    final result = await Parser.instance.svgToMuscleList(widget.map);
    _muscleList.clear();
    setState(() {
      _muscleList.addAll(result.muscles);
      mapSize = result.mapSize;
      _sizeController.mapSize = result.mapSize;
      _isLoading = false;
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
    final content = _isLoading
        ? _buildLoading(context)
        : Stack(
            key: ValueKey('map-${widget.map}'),
            children: [
              for (var muscle in _muscleList) _buildStackItem(muscle),
            ],
          );

    if (!widget.enableCrossfade) {
      return content;
    }

    return AnimatedSwitcher(
      duration: widget.crossfadeDuration,
      child: content,
    );
  }

  Widget _buildLoading(BuildContext context) {
    if (widget.loadingBuilder != null) {
      return KeyedSubtree(
        key: const ValueKey('skeleton'),
        child: widget.loadingBuilder!(context),
      );
    }
    if (!widget.showSkeleton) {
      return SizedBox(
        key: const ValueKey('skeleton'),
        width: widget.width,
        height: widget.height,
      );
    }
    return MuscleMapSkeleton(
      key: const ValueKey('skeleton'),
      width: widget.width,
      height: widget.height,
      color: widget.skeletonColor,
      animationDuration: widget.skeletonAnimationDuration,
      opacityBegin: widget.skeletonOpacityBegin,
      opacityEnd: widget.skeletonOpacityEnd,
      curve: widget.skeletonCurve,
      borderRadius: widget.skeletonBorderRadius,
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
          strokeWidth: widget.strokeWidth,
          strokeCap: widget.strokeCap,
          strokeJoin: widget.strokeJoin,
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

  Color getMuscleColor(Muscle muscle) {
    if (widget.intensityColorBuilder != null) {
      return widget.intensityColorBuilder!(muscle.intensity);
    }
    switch (muscle.intensity) {
      case MuscleIntensity.none:
        return intensity_colors.Colors.none_intensity;
      case MuscleIntensity.light:
        return intensity_colors.Colors.light_intensity;
      case MuscleIntensity.medium:
        return intensity_colors.Colors.medium_intensity;
      case MuscleIntensity.hard:
        return intensity_colors.Colors.hard_intensity;
    }
  }
}
