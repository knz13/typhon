import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;

import 'html_with_mathjax.dart';
import 'mathjax_handlers.dart';
import 'node_handler.dart';

class TextNodeHandler extends NodeHandler {
  TextNodeHandler(HtmlWithMathJaxView view, dom.Text node, TextStyle style) : super(view, node, style);

  @override
  List<InlineSpan> handle() {
    List<InlineSpan> spans = [];
    int currentPos = 0;

    final RegExp regex = RegExp(r'\\\[.*?\\\]|\\\(.*?\\\)|\$\$.*?\$\$');
    String nodeText = node?.text ?? "";
    Iterable<RegExpMatch> matches = regex.allMatches(nodeText);

    for (RegExpMatch match in matches) {
      String segment = nodeText.substring(currentPos, match.start);
      if (segment.isNotEmpty) {
        spans.add(TextSpan(text: segment));
      }

      String matchStr = match[0]!;
      if (matchStr.startsWith(r'\(') && matchStr.endsWith(r'\)')) {
        spans.addAll(
          InlineMathHandler(view, matchStr.substring(2, matchStr.length - 2), style).handle(),
        );
      } else if (matchStr.startsWith(r'\[') && matchStr.endsWith(r'\]')) {
        spans.addAll(
          DisplayMathHandler(view, matchStr.substring(2, matchStr.length - 2), style).handle(),
        );
      } else if (matchStr.startsWith(r'$$') && matchStr.endsWith(r'$$')) {
        spans.addAll(
          DisplayMathHandler(view, matchStr.substring(2, matchStr.length - 2), style).handle(),
        );
      }
      currentPos = match.end;
    }

    if (currentPos < nodeText.length) {
      spans.add(TextSpan(text: nodeText.substring(currentPos)));
    }

    return spans;
  }
}
