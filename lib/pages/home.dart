import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:poetry_ai/components/template_card.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final _myBox = Hive.box('myBox');
  final globalThemeBox = Hive.box('myThemeBox');
  PoetryType poetryTypeName = PoetryType("", "", [""]);
  bool isTemplateClicked = false;
  List<String> features = [""];
  int selectedTemplateIndex = -1;
  @override
  void initState() {
    globalThemeBox.get('theme');
    super.initState();
    _controller = AnimationController(
      value: 0.0,
      duration: const Duration(seconds: 10),
      upperBound: 1,
      lowerBound: -1,
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
