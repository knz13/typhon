import 'package:flutter/material.dart';

import '../../../../config/theme.dart';

class SelectableButtonWidget extends StatefulWidget {
  const SelectableButtonWidget({
    super.key,
    required this.onPressed,
    this.child,
    this.minWidth,
    this.height,
    this.color = ConfigColors.blueColor,
    this.selectedColor = ConfigColors.activeColor,
    this.selected,
    this.colorChangeDuration = const Duration(seconds: 1),
    this.disabled = false
  });

  final bool disabled;
  final void Function(bool) onPressed;
  final Widget? child;
  final double? minWidth;
  final double? height;
  final Color? selectedColor;
  final Color? color;
  final bool? selected;
  final Duration? colorChangeDuration;

  @override
  State<SelectableButtonWidget> createState() => _SelectableButtonWidgetState();
}

class _SelectableButtonWidgetState extends State<SelectableButtonWidget> {
  bool selected = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: MaterialButton(
        
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        splashColor: Colors.transparent,
        color: widget.selected != null
            ? (widget.selected! ? widget.selectedColor : widget.color)
            : (selected ? widget.selectedColor : widget.color),
        height: widget.height,
        minWidth: widget.minWidth,
        onPressed: widget.disabled? null : () {
          setState(() {
            selected = !selected;
          });
          widget.onPressed(selected);
        },
        child: widget.child,
      ),
    );
  }
}
