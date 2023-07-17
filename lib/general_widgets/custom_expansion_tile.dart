




import 'package:flutter/material.dart';
import 'package:typhon/general_widgets.dart';

class CustomExpansionTile extends StatefulWidget {
  final Widget title;
  final List<Widget> children;
  final Widget icon;

  CustomExpansionTile({required this.title, required this.children,this.icon = const Icon(Icons.expand_more)});

  @override
  _CustomExpansionTileState createState() => _CustomExpansionTileState();
}

class _CustomExpansionTileState extends State<CustomExpansionTile> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _controller;
  late Animation<double> _iconTurns;

  void _handleTap() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse().then<void>((value) {
          setState(() {
            // Rebuild without widget.children.
          });
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: kThemeAnimationDuration, vsync: this);
    _iconTurns = _controller.drive(Tween<double>(begin: 0, end: 0.25));
  }

  @override
  Widget build(BuildContext context) {
    return widget.children.length > 0 ? Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: <Widget>[
            GeneralButton(
              needsHoverColor: false,
              child: RotationTransition(
                turns: _iconTurns,
                child: RotatedBox(
                  quarterTurns: 3,
                  child: widget.icon,
                )
              ),
              onPressed: _handleTap,
            ),
            Expanded(
              child: widget.title,
            ),
          ],
        ),
        if (_isExpanded) ...widget.children
      ],
    ) : widget.title;
  }
}