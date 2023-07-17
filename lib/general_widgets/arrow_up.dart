import 'dart:math';

import 'package:flutter/material.dart';

class ArrowUp extends StatelessWidget {
  final double size;
  final double strokeWidth;
  final Color color;

  ArrowUp({required this.size, this.color = Colors.black,this.strokeWidth = 2});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size), // Specify the size of the square.
      painter: _ArrowUpPainter(color,strokeWidth: strokeWidth), // Your custom painter.
    );
  }
}

class _ArrowUpPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  _ArrowUpPainter(this.color,{required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    paint.color = color;

    var path = Path();
    path.moveTo(size.width/2,size.height/4); 
    path.lineTo(size.width/4,size.height*3/4);
    path.lineTo(size.width*3/4, size.height*3/4);

    canvas.drawPath(path, paint); // Draw the path.
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}