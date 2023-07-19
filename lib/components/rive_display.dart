import 'package:flutter/material.dart';

class DisplayRive extends StatelessWidget {
  const DisplayRive(
      {super.key,
      required this.rive,
      required this.riveHeight,
      required this.riveWidth});
  final Widget rive;
  final double riveHeight;
  final double riveWidth;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: riveWidth,
      height: riveHeight,
      child: rive,
    );
  }
}
