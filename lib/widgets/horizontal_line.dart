import 'package:flutter/material.dart';

class HorizontalLine extends StatelessWidget {
  final double size;
  final double strokeWidth;
  final Color color;

  HorizontalLine({required this.size, this.color = Colors.black,this.strokeWidth = 2});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size), // Specify the size of the square.
      painter: _HorizontalLinePainter(color,strokeWidth: strokeWidth), // Your custom painter.
    );
  }
}

class _HorizontalLinePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  _HorizontalLinePainter(this.color,{required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    paint.color = color;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = strokeWidth;

    var path = Path();
    path.moveTo(0, size.height/2); 
    path.relativeLineTo(size.width*3/4, 0);

    canvas.drawPath(path, paint); // Draw the path.
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}