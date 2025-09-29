import 'dart:ui';

import 'package:muscle_selector/src/models/MuscleIntensity.dart';

class Muscle {
  String id;
  String title;
  Path path;
  MuscleIntensity  intensity;

  Muscle({required this.id, required this.title, required this.path, this.intensity = MuscleIntensity.none});
}

