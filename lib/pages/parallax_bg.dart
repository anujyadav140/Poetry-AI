import 'package:flutter/material.dart';

class ParallaxBackground extends StatelessWidget {
  const ParallaxBackground({
    super.key,
    required this.asset,
    this.top,
  });

  final double? top;
  final String asset;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: 0,
      right: 0,
      child: SizedBox(
        height: 351,
        child: Image(
          image: AssetImage(asset),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
