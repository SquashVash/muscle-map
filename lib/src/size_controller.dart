import 'dart:ui';

class SizeController {
  static SizeController? _instance;

  static SizeController get instance {
    _instance ??= SizeController._init();
    return _instance!;
  }

  SizeController._init();

  Size mapSize = Size.zero;

  double calculateScale(Size? containerSize) {
    if (containerSize == null) {
      return 1.0;
    }

    double newWidth = containerSize.width, newHeight = containerSize.height;
    if (containerSize.width > containerSize.height) {
      newHeight = 1 /(mapSize.aspectRatio / containerSize.width);
    }
    else {
      newHeight = containerSize.width / mapSize.aspectRatio;
    }
    containerSize = Size(newWidth, newHeight);

    double scale1 = containerSize.width / mapSize.width;
    double scale2 = containerSize.height / mapSize.height;
    double mapScale = scale1 > scale2 ? scale1 : scale2;

    return mapScale;
  }

  double inverseOfScale(double scale) => 1.0/scale;
}