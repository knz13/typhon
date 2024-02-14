import 'package:flutter/material.dart';
import 'package:typhon/native_context_menu/native_context_menu.dart';

class NativeContextMenuArea extends StatefulWidget {
  NativeContextMenuArea(
      {required this.child,
      required this.menuItems,
      Key? key,
      this.menuOffset = Offset.zero,
      this.color,
      this.secondaryTap = false})
      : super(key: key);

  final Widget child;
  Color? color;
  final List<ContextMenuOption> menuItems;
  final Offset menuOffset;
  bool secondaryTap;

  @override
  State<NativeContextMenuArea> createState() => _NativeContextMenuAreaState();
}

class _NativeContextMenuAreaState extends State<NativeContextMenuArea> {
  bool shouldReact = false;

  Offset mousePos = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
        onHover: (ev) {
          mousePos = ev.position;
        },
        child: InkWell(
            mouseCursor: SystemMouseCursors.move,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            hoverColor: Theme.of(context).highlightColor,
            onTap: !widget.secondaryTap
                ? () {
                    showNativeContextMenu(
                        context, mousePos.dx, mousePos.dy, widget.menuItems);
                  }
                : null,
            onSecondaryTap: widget.secondaryTap
                ? () {
                    showNativeContextMenu(
                        context, mousePos.dx, mousePos.dy, widget.menuItems);
                  }
                : null,
            child: widget.child));
  }
}
