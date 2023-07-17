


import 'package:flutter/material.dart';
import 'package:typhon/general_widgets.dart';
import 'package:typhon/general_widgets/arrow_up.dart';

class RotatingArrowButton extends StatefulWidget {
  RotatingArrowButton({super.key,required this.onTap,required this.size,required this.value});

  bool value;
  void Function() onTap;
  double size;

  @override
  State<RotatingArrowButton> createState() => _RotatingArrowButtonState();
}

class _RotatingArrowButtonState extends State<RotatingArrowButton> {

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return InkWell(
        onTap: widget.onTap,
        child: AnimatedRotation(
          duration: Duration(milliseconds: 200),
          turns: widget.value? 0.5 : 0.25,
          child: ArrowUp(size: widget.size,color: platinumGray,)
        ),
      );
  }
}