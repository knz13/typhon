import 'package:flutter/material.dart';
import 'package:typhon/config/theme.dart';

class TyphonButtonWidget extends StatelessWidget {
  const TyphonButtonWidget(
      {this.child,
      super.key,
      this.width,
      this.onPressed,
      this.height,
      this.color = ConfigColors.blueColor,
      this.borderRadius});

  final Widget? child;
  final double? height;
  final double? width;
  final Color? color;
  final BorderRadius? borderRadius;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    Widget button = MaterialButton(
      splashColor: Colors.transparent,
      onPressed: onPressed ?? () {},
      height: height,
      color: color,
      minWidth: width,
      shape: RoundedRectangleBorder(
          borderRadius: borderRadius ?? BorderRadius.circular(5)),
      child: child,
    );
    if (width == null) {
      button = SizedBox(
        height: height,
        child: button,
      );
    } else {
      button = SizedBox(
        height: height,
        child: button,
      );
    }

    return button;
  }
}
