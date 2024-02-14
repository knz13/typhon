



import 'package:flutter/material.dart';

class VerticalSpacing extends StatelessWidget {
  const VerticalSpacing(this.size,{super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SizedBox(
      height: size,
    );
  }
}

class HorizontalSpacing extends StatelessWidget {
  const HorizontalSpacing(this.size,{super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SizedBox(
      width: size,
    );
  }
}