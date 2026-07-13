import 'package:flutter/material.dart';

class MuscleMapSkeleton extends StatefulWidget {
  final double? width;
  final double? height;
  final Color? color;

  const MuscleMapSkeleton({
    Key? key,
    this.width,
    this.height,
    this.color,
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
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
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
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
