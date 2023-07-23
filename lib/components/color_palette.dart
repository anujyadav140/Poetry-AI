import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class GreenColorTheme {
  static const Color text = Color.fromRGBO(255, 255, 255, 1);
  static const Color background = Color.fromRGBO(248, 232, 246, 1);
  static const Color primary = Color.fromRGBO(150, 223, 158, 1);
  static const Color secondary = Color.fromRGBO(177, 225, 231, 1);
  static const Color accent = Color.fromRGBO(48, 156, 61, 1);
  static const String riveEmptyListAnimation = "assets/empty-living-room.riv";
}

class PurpleColorTheme {
  static const Color text = Color.fromRGBO(0, 0, 0, 1);
  static const Color background = Color.fromRGBO(75, 73, 219, 1);
  static const Color primary = Color.fromRGBO(169, 126, 169, 1);
  static const Color secondary = Color.fromRGBO(235, 224, 230, 1);
  static const Color accent = Color.fromRGBO(127, 102, 153, 1);
  static const String riveEmptyListAnimation = "assets/empty-living-room.riv";
}

class ClassicColorTheme {
  static const Color text = Color.fromRGBO(0, 0, 0, 1);
  static const Color background = Color.fromRGBO(215, 215, 215, 1);
  static const Color primary = Color.fromRGBO(255, 255, 255, 1);
  static const Color secondary = Color.fromRGBO(255, 255, 255, 1);
  static const String riveEmptyListAnimation =
      "assets/living_room_scene_b&w.riv";
}

class ColorTheme {
  final globalThemeBox = Hive.box('myThemeBox');

  static Color text(String color) {
    if (color == "Green") {
      return GreenColorTheme.text;
    } else if (color == "Purple") {
      return PurpleColorTheme.text;
    } else if (color == "Classic") {
      return ClassicColorTheme.text;
    } else {
      return Colors.black;
    }
  }

  static Color background(String color) {
    if (color == "Green") {
      return Colors.green.shade100;
    } else if (color == "Purple") {
      return Colors.purple.shade100;
    } else if (color == "Classic") {
      return ClassicColorTheme.background;
    } else {
      return Colors.white;
    }
  }

  static Color primary(String color) {
    if (color == "Green") {
      return GreenColorTheme.primary;
    } else if (color == "Purple") {
      return PurpleColorTheme.primary;
    } else if (color == "Classic") {
      return ClassicColorTheme.primary;
    } else {
      return Colors.blue;
    }
  }

  static Color secondary(String color) {
    if (color == "Green") {
      return GreenColorTheme.secondary;
    } else if (color == "Purple") {
      return PurpleColorTheme.secondary;
    } else if (color == "Classic") {
      return ClassicColorTheme.secondary;
    } else {
      return Colors.red;
    }
  }

  static Color accent(String color) {
    if (color == "Green") {
      return GreenColorTheme.accent;
    } else if (color == "Purple") {
      return PurpleColorTheme.accent;
    } else if (color == "Classic") {
      return ClassicColorTheme.background;
    } else {
      return Colors.indigo;
    }
  }

  static String riveEmptyListAnimation(String rive) {
    if (rive == "Green") {
      return GreenColorTheme.riveEmptyListAnimation;
    } else if (rive == "Purple") {
      return PurpleColorTheme.riveEmptyListAnimation;
    } else if (rive == "Classic") {
      return ClassicColorTheme.riveEmptyListAnimation;
    } else {
      return GreenColorTheme.riveEmptyListAnimation;
    }
  }
}
