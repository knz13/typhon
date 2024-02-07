import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

import 'html_with_mathjax.dart';
import 'node_handler.dart';

class InlineMathHandler extends NodeHandler {
  final String latex;

  InlineMathHandler(HtmlWithMathJaxView view,this.latex, TextStyle style) : super(view,null, style);

  @override
  List<InlineSpan> handle() {
    return [
      WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Math.tex(
            latex,
            textStyle: style,
            options: MathOptions(color: style.color ?? Colors.black, fontSize: style.fontSize),
          ))
    ];
  }
}

class DisplayMathHandler extends NodeHandler {
  final String latex;

  DisplayMathHandler(HtmlWithMathJaxView view,this.latex, TextStyle style) : super(view,null, style);

  @override
  List<InlineSpan> handle() {
    return [
      WidgetSpan(
        child: Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Math.tex(
              latex,
              mathStyle: MathStyle.display,
            ),
          ),
        ),
      ),
    ];
  }
}
