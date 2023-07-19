import 'package:flutter/material.dart';

class Template extends StatelessWidget {
  final Color templateBoxColor;
  final Color templateSplashColor;
  const Template({super.key, required this.templateBoxColor, required this.templateSplashColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 8.0,
        left: 10.0,
        bottom: 15.0,
        right: 10.0,
      ),
      child: InkWell(
        // splashColor: ColorTheme.accent(globalThemeBox.get('theme')),
        splashColor: templateSplashColor,
        borderRadius: BorderRadius.circular(20.0),
        onTap: () {
          print("Clicked on template!");
        },
        child: Ink(
          decoration: BoxDecoration(
            // color: ColorTheme.primary(globalThemeBox.get('theme')),
            color: templateBoxColor,
            borderRadius: BorderRadius.circular(20.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: SizedBox(
            height: 200,
            width: MediaQuery.of(context).size.width * 0.8,
            child: const Text("Sonnet"),
          ),
        ),
      ),
    );
  }
}
