import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class GreenColorTheme {
  static const Color text = Color.fromRGBO(27, 8, 25, 1);
  static const Color background = Color.fromRGBO(248, 232, 246, 1);
  static const Color primary = Color.fromRGBO(150, 223, 158, 1);
  static const Color secondary = Color.fromRGBO(177, 225, 231, 1);
  static const Color accent = Color.fromRGBO(48, 156, 61, 1);
}

class PurpleColorTheme {
  static const Color text = Color.fromRGBO(0, 0, 0, 1);
  static const Color background = Color.fromRGBO(75, 73, 219, 1);
  static const Color primary = Color.fromRGBO(169, 126, 169, 1);
  static const Color secondary = Color.fromRGBO(235, 224, 230, 1);
  static const Color accent = Color.fromRGBO(127, 102, 153, 1);
}

class ColorTheme {
  final globalThemeBox = Hive.box('myThemeBox');

  static Color text(String color) {
    // Return different color based on the selected theme
    if (color == "Green") {
      return GreenColorTheme.text;
    } else if (color == "Purple") {
      return PurpleColorTheme.text;
    } else {
      return Colors.black; // Return a default color if no theme is selected
    }
  }

  static Color background(String color) {
    // Return different color based on the selected theme
    if (color == "Green") {
      return Colors.green.shade100;
    } else if (color == "Purple") {
      return Colors.purple.shade100;
    } else {
      return Colors.white; // Return a default color if no theme is selected
    }
  }

  static Color primary(String color) {
    // Return different color based on the selected theme
    if (color == "Green") {
      return GreenColorTheme.primary;
    } else if (color == "Purple") {
      return PurpleColorTheme.primary;
    } else {
      return Colors.blue; // Return a default color if no theme is selected
    }
  }

  static Color secondary(String color) {
    // Return different color based on the selected theme
    if (color == "Green") {
      return GreenColorTheme.secondary;
    } else if (color == "Purple") {
      return PurpleColorTheme.secondary;
    } else {
      return Colors.red; // Return a default color if no theme is selected
    }
  }

  static Color accent(String color) {
    // Return different color based on the selected theme
    if (color == "Green") {
      return GreenColorTheme.accent;
    } else if (color == "Purple") {
      return PurpleColorTheme.accent;
    } else {
      return Colors.indigo; // Return a default color if no theme is selected
    }
  }
}
