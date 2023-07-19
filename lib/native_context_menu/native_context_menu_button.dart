import 'package:flutter/material.dart';
import 'package:typhon/native_context_menu/native_context_menu.dart';

class NativeContextMenuButton extends StatefulWidget {
  NativeContextMenuButton({
    required this.child,
    required this.menuItems,
    Key? key,
    this.menuOffset = Offset.zero,
    this.color
  }) : super(key: key);

  final Widget child;
  Color? color;
  final List<ContextMenuOption> menuItems;
  final Offset menuOffset;

  @override
  State<NativeContextMenuButton> createState() => _NativeContextMenuButtonState();
}

class _NativeContextMenuButtonState extends State<NativeContextMenuButton> {
  bool shouldReact = false;

  Offset mousePos = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (ev) {
        mousePos = ev.position;
      },
      child: MaterialButton(
        color: widget.color,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Theme.of(context).highlightColor,
        animationDuration: Duration.zero,
        onPressed: () {
          showNativeContextMenu(context, mousePos.dx, mousePos.dy, widget.menuItems);
        },
        minWidth: 0,
        padding: EdgeInsets.zero,
        child: widget.child
      )
    );
  }
}