




import 'package:flutter/material.dart';
import 'package:typhon/widgets/general_widgets.dart';
import 'package:typhon/widgets/rotating_arrow_button.dart';

class CustomExpansionTile extends StatefulWidget {
  final Widget title;
  final List<Widget> children;
  final Widget icon;
  final bool initialValue;

  CustomExpansionTile({required this.title, required this.children,this.initialValue = true,this.icon = const Icon(Icons.expand_more)});

  @override
  _CustomExpansionTileState createState() => _CustomExpansionTileState();
}

class _CustomExpansionTileState extends State<CustomExpansionTile> with SingleTickerProviderStateMixin {
  late bool _isExpanded;
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
    _isExpanded = widget.initialValue;
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
            RotatingArrowButton(onTap: _handleTap, size: 20, value: _isExpanded),
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