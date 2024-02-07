import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;

import 'html_with_mathjax.dart';
import 'node_handler.dart';

class CenterNodeHandler extends SpecialNodeHandler {
  CenterNodeHandler(HtmlWithMathJaxView view,dom.Element node, TextStyle style) : super(view,node, style);

  @override
  List<Widget> handle() {
    return [
      Align(
          alignment: Alignment.center,
          child: Column(
            children: [
              ...HtmlWithMathJaxView.buildChildrenFromNode(view,node!, style,
                  textAlign: TextAlign.center)
            ],
          ))
    ];
  }
}
