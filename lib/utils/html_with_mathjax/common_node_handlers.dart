import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;

import 'html_with_mathjax.dart';
import 'node_handler.dart';

class UnderlineTextHandler extends NodeHandler {
  UnderlineTextHandler(HtmlWithMathJaxView view, dom.Element node, TextStyle style) : super(view, node, style);

  @override
  List<InlineSpan> handle() {
    return [
      TextSpan(
        children: HtmlWithMathJaxView.buildChildrenFromNodeInSpan(
            view, node!, style.copyWith(decoration: TextDecoration.underline),
            textAlign: TextAlign.center),
        style: style.copyWith(decoration: TextDecoration.underline),
      ),
    ];
  }
}

class StyledHandler extends NodeHandler {
  StyledHandler(HtmlWithMathJaxView view, dom.Element node, TextStyle style) : super(view, node, style);

  @override
  List<InlineSpan> handle() {
    double? fontSize = _getFontSizeFromNode(node);
    Color? color = _getColorFromNode(node);
    TextStyle newStyle = style.copyWith(fontSize: fontSize, color: color);

    return [
      TextSpan(
        children: HtmlWithMathJaxView.buildChildrenFromNodeInSpan(view, node!, newStyle, textAlign: TextAlign.center),
        style: newStyle,
      ),
    ];
  }

  // Helper function to extract font size information from the node
  double? _getFontSizeFromNode(dom.Node? node) {
    if (node != null && node.attributes['style'] != null) {
      // Updated RegExp to match floating-point numbers
      RegExp fontSizeRegExp = RegExp(r'font-size:\s*([\d\.]+)(px|em)');
      Match? match = fontSizeRegExp.firstMatch(node.attributes['style']!);
      if (match != null) {
        double size = double.parse(match.group(1)!); // Parses as double
        String unit = match.group(2)!;

        // Convert to pixels if necessary (assuming 1em = 16px)
        if (unit == 'em') {
          size *= 16;
        }
        return size;
      }
    }
    return null; // Return null if no font size found
  }

  // Helper function to extract color information from the node
  Color? _getColorFromNode(dom.Node? node) {
    if (node != null && node.attributes['style'] != null) {
      RegExp colorRegExp = RegExp(r'color:\s*(#(?:[0-9a-fA-F]{3}){1,2})');
      Match? match = colorRegExp.firstMatch(node.attributes['style']!);
      if (match != null) {
        String colorString = match.group(1)!;
        return Color(int.parse(colorString.substring(1), radix: 16) + 0xFF000000);
      }
    }
    return null; // Return null if no color found
  }
}

class SubscriptTextHandler extends NodeHandler {
  SubscriptTextHandler(HtmlWithMathJaxView view, dom.Element node, TextStyle style) : super(view, node, style);

  @override
  List<InlineSpan> handle() {
    return [
      TextSpan(
        children: HtmlWithMathJaxView.buildChildrenFromNodeInSpan(
            view, node!, style.copyWith(fontSize: style.fontSize != null ? style.fontSize! - 2 : null),
            textAlign: TextAlign.center),
        style: style.copyWith(fontSize: style.fontSize != null ? style.fontSize! - 2 : null),
      ),
    ];
  }
}

class StrongTextHandler extends NodeHandler {
  StrongTextHandler(HtmlWithMathJaxView view, dom.Element node, TextStyle style) : super(view, node, style);

  @override
  List<InlineSpan> handle() {
    return [
      TextSpan(
        children: HtmlWithMathJaxView.buildChildrenFromNodeInSpan(
            view, node!, style.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center),
        style: style.copyWith(fontWeight: FontWeight.bold),
      ),
    ];
  }
}

class ItalicTextHandler extends NodeHandler {
  ItalicTextHandler(HtmlWithMathJaxView view, dom.Element node, TextStyle style) : super(view, node, style);

  @override
  List<InlineSpan> handle() {
    return [
      TextSpan(
        children:
            HtmlWithMathJaxView.buildChildrenFromNodeInSpan(view, node!, style.copyWith(fontStyle: FontStyle.italic)),
        style: style.copyWith(fontStyle: FontStyle.italic),
      ),
    ];
  }
}

class NewlineHandler extends NodeHandler {
  NewlineHandler(HtmlWithMathJaxView view, dom.Element node, TextStyle style) : super(view, node, style);

  @override
  List<InlineSpan> handle() {
    return [
      const TextSpan(
        text: "\n",
      ),
    ];
  }
}
