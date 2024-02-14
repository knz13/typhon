


import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;

import 'html_with_mathjax.dart';

abstract class NodeHandler {
  final dom.Node? node;
  final TextStyle style;
  final HtmlWithMathJaxView view;

  NodeHandler(this.view,this.node,this.style);

  List<InlineSpan> handle();
}


abstract class SpecialNodeHandler {
  final dom.Node? node;
  final TextStyle style;
  final HtmlWithMathJaxView view;


  SpecialNodeHandler(this.view,this.node,this.style);

  List<Widget> handle();
}