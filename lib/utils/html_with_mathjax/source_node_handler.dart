import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;

import 'html_with_mathjax.dart';
import 'node_handler.dart';

class SourceNodeHandler extends SpecialNodeHandler {
  SourceNodeHandler(HtmlWithMathJaxView view,dom.Element node, TextStyle style) : super(view,node, style);

  @override
  List<Widget> handle() {
    return [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: SizedBox(
          width: double.infinity,
          child: Align(
            alignment: Alignment.centerRight,
            child: RichText(
              text: TextSpan(style: style, children: HtmlWithMathJaxView.buildChildrenFromNodeInSpan(view,node!, style)),
              textAlign: TextAlign.right,
            ),
          ),
        ),
      ),
    ];
  }
}
