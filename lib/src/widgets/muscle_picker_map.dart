import 'dart:async';

import 'package:flutter/material.dart';
import 'package:muscle_map/muscle_map.dart';
import 'package:muscle_map/src/widgets/muscle_painter.dart';
import 'package:muscle_map/src/widgets/muscle_map_skeleton.dart';
import '../parser.dart';
import '../size_controller.dart';

class MusclePickerMap extends StatefulWidget {
  final double? width;
  final double? height;
  final String map;
  final Function(Set<Muscle> muscles) onChanged;
  final Color? strokeColor;
  final Color? selectedColor;
  final Color? dotColor;
  final bool? actAsToggle;
  final bool? isEditing;
  final Set<Muscle>? initialSelectedMuscles;
  final List<String>? initialSelectedGroups;
  final bool enableCrossfade;
  final Duration crossfadeDuration;
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

  const MusclePickerMap({
    Key? key,
    required this.map,
    required this.onChanged,
    this.width,
    this.height,
    this.strokeColor,
    this.selectedColor,
    this.dotColor,
    this.actAsToggle,
    this.isEditing = false,
    this.initialSelectedMuscles,
    this.initialSelectedGroups,
    this.enableCrossfade = true,
    this.crossfadeDuration = const Duration(milliseconds: 100),
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
  MusclePickerMapState createState() => MusclePickerMapState();
}

class MusclePickerMapState extends State<MusclePickerMap> {
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
  void didUpdateWidget(covariant MusclePickerMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.map != widget.map) {
      setState(() {
        selectedMuscles.clear();
        _isLoading = true;
      });
      _loadMuscleList();
    }
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
      final groupMuscles = Parser.instance.getMusclesByGroups(widget.initialSelectedGroups!, _muscleList);
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

    final bool isSelectable = muscle.id != 'human_body' && !widget.isEditing!;

    return GestureDetector(
      behavior: HitTestBehavior.deferToChild,
      onTap: () => {
        if (isSelectable) {
          (widget.actAsToggle ?? false) ? _toggleButton(muscle) : _useButton(muscle)
        }
      },
      child: CustomPaint(
        isComplex: true,
        foregroundPainter: MusclePainter(
          muscle: muscle,
          selectedMuscles: selectedMuscles,
          dotColor: widget.dotColor,
          selectedColor: widget.selectedColor,
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

  void _toggleButton(Muscle muscle) {
    setState(() {
      final group = Parser.muscleGroups.entries.firstWhere(
            (entry) => entry.value.contains(muscle.id),
        orElse: () => const MapEntry('', []),
      );

      if (group.key.isNotEmpty) {
        final relatedMuscles = _muscleList.where((m) => group.value.contains(m.id)).toList();
        if (relatedMuscles.every((m) => selectedMuscles.contains(m))) {
          selectedMuscles.removeAll(relatedMuscles);
        } else {
          selectedMuscles.addAll(relatedMuscles);
        }
      } else {
        if (selectedMuscles.contains(muscle)) {
          selectedMuscles.remove(muscle);
        } else {
          selectedMuscles.add(muscle);
        }
      }
      widget.onChanged.call(selectedMuscles);
    });
  }

  void _useButton(Muscle muscle) {
    setState(() {
      final group = Parser.muscleGroups.entries.firstWhere(
            (entry) => entry.value.contains(muscle.id),
        orElse: () => const MapEntry('', []),
      );

      if (group.key.isNotEmpty) {
        final relatedMuscles = _muscleList.where((m) => group.value.contains(m.id)).toList();
        selectedMuscles.addAll(relatedMuscles);
      } else {
        selectedMuscles.add(muscle);
      }
      widget.onChanged.call(selectedMuscles);
    });
  }
}
