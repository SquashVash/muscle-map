import 'package:flutter/material.dart';

class MuscleMapSkeleton extends StatefulWidget {
  final double? width;
  final double? height;
  final Color? color;
  final Duration animationDuration;
  final double opacityBegin;
  final double opacityEnd;
  final Curve curve;
  final double borderRadius;

  const MuscleMapSkeleton({
    Key? key,
    this.width,
    this.height,
    this.color,
    this.animationDuration = const Duration(milliseconds: 900),
    this.opacityBegin = 0.4,
    this.opacityEnd = 1.0,
    this.curve = Curves.easeInOut,
    this.borderRadius = 16,
  }) : super(key: key);

  @override
  State<MuscleMapSkeleton> createState() => _MuscleMapSkeletonState();
}

class _MuscleMapSkeletonState extends State<MuscleMapSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: widget.opacityBegin, end: widget.opacityEnd).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width ?? double.infinity,
      height: widget.height ?? double.infinity,
      child: FadeTransition(
        opacity: _opacity,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: widget.color ?? Colors.grey.shade300,
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
        ),
      ),
    );
  }
}
