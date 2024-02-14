import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html;

import '../../config/size_config.dart';
import 'center_node_handler.dart';
import 'common_node_handlers.dart';
import 'img_node_handler.dart';
import 'source_node_handler.dart';
import 'text_node_handler.dart';

class HtmlWithMathJaxView extends StatelessWidget {
  static final Map<String, List<InlineSpan> Function(HtmlWithMathJaxView, dom.Node, TextStyle)> nodeHandlers = {
    'math': (view, node, style) => TextNodeHandler(view, node as dom.Text, style).handle(),
    '#text': (view, node, style) => TextNodeHandler(view, node as dom.Text, style).handle(),
    'strong': (view, node, style) => StrongTextHandler(view, node as dom.Element, style).handle(),
    'b': (view, node, style) => StrongTextHandler(view, node as dom.Element, style).handle(),
    'sub': (view, node, style) => SubscriptTextHandler(view, node as dom.Element, style).handle(),
    'i': (view, node, style) => ItalicTextHandler(view, node as dom.Element, style).handle(),
    'u': (view, node, style) => UnderlineTextHandler(view, node as dom.Element, style).handle(),
    'br': (view, node, style) => NewlineHandler(view, node as dom.Element, style).handle(),
    'styled': (view, node, style) => StyledHandler(view, node as dom.Element, style).handle(),
  };

  static final Map<String, List<Widget> Function(HtmlWithMathJaxView, dom.Node, TextStyle)> specialNodeHandlers = {
    'img': (view, node, style) => ImgNodeHandler(view, node as dom.Element, style).handle(),
    'source': (view, node, style) => SourceNodeHandler(view, node as dom.Element, style).handle(),
    'center-text': (view, node, style) => CenterNodeHandler(view, node as dom.Element, style).handle(),
  };

  static double globalImageWidthMultiplier = kIsWeb ? 0.2 : 1;

  final String code;
  final TextStyle style;
  final bool clickToViewImageCloser;
  final double? overrideImgWidth;
  final TextAlign textAlign;

  const HtmlWithMathJaxView(
      {super.key,
      required this.code,
      this.textAlign = TextAlign.left,
      this.clickToViewImageCloser = true,
      this.overrideImgWidth,
      this.style = const TextStyle()});

  @override
  Widget build(BuildContext context) {
    String cleanedLatexCode = code.replaceAll('<p>', '').replaceAll('</p>', '');
    return SingleChildScrollView(
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: _buildChildren(cleanedLatexCode),
        ),
      ),
    );
  }

  static List<InlineSpan> buildChildrenFromNodeInSpan(HtmlWithMathJaxView view, dom.Node node, TextStyle style,
      {TextAlign? textAlign}) {
    List<InlineSpan> currentSpans = [];
    dom.NodeList childrenElements = node.nodes;

    for (var node in childrenElements) {
      String nodeType = node is dom.Text ? "#text" : (node as dom.Element).localName!;
      var handlerFactory = nodeHandlers[nodeType];
      if (handlerFactory != null) {
        final spans = handlerFactory(view, node, style);
        currentSpans.addAll(spans);
      }
    }

    return currentSpans;
  }

  static List<Widget> buildChildrenFromNode(HtmlWithMathJaxView view, dom.Node node, TextStyle style,
      {TextAlign? textAlign}) {
    List<InlineSpan> currentSpans = [];
    List<Widget> children = [];
    dom.NodeList childrenElements = node.nodes;

    void addCurrentSpans() {
      if (currentSpans.isNotEmpty) {
        children.add(SizedBox(
          width: double.infinity,
          child: RichText(
            textAlign: textAlign ?? TextAlign.left,
            text: TextSpan(
              children: currentSpans,
              style: style,
            ),
          ),
        ));
        currentSpans = [];
      }
    }

    for (var node in childrenElements) {
      String nodeType = node is dom.Text ? "#text" : (node as dom.Element).localName!;
      var handlerFactory = nodeHandlers[nodeType];
      if (handlerFactory != null) {
        final spans = handlerFactory(view, node, style);
        currentSpans.addAll(spans);
      } else {
        var specialHandlerFactory = specialNodeHandlers[nodeType];
        if (specialHandlerFactory != null) {
          addCurrentSpans();
          final childrenToAdd = specialHandlerFactory(view, node, style);
          children.addAll(childrenToAdd);
        }
        if (nodeType == "span") {
          if ((node as dom.Element).className == "source") {
            addCurrentSpans();
            final childrenToAdd = specialNodeHandlers["source"]!(view, node, style);
            children.addAll(childrenToAdd);
          }
          if ((node).className == "center-text") {
            addCurrentSpans();
            final childrenToAdd = specialNodeHandlers["center-text"]!(view, node, style);
            children.addAll(childrenToAdd);
          }
        }
      }
    }

    addCurrentSpans();

    return children;
  }

  List<Widget> _buildChildren(String code) {
    List<Widget> children = [];
    dom.Document document = html.parse(code);

    List<InlineSpan> currentSpans = [];

    void addCurrentSpans() {
      if (currentSpans.isNotEmpty) {
        children.add(SizedBox(
          width: double.infinity,
          child: RichText(
            textAlign: textAlign,
            text: TextSpan(
              children: currentSpans,
              style: style,
            ),
          ),
        ));
        currentSpans = [];
      }
    }

    for (var node in document.body!.nodes) {
      String nodeType = node is dom.Text ? "#text" : (node as dom.Element).localName!;
      var handlerFactory = nodeHandlers[nodeType];
      if (handlerFactory != null) {
        final spans = handlerFactory(this, node, style);
        currentSpans.addAll(spans);
      } else {
        var specialHandlerFactory = specialNodeHandlers[nodeType];
        if (specialHandlerFactory != null) {
          addCurrentSpans();
          final childrenToAdd = specialHandlerFactory(this, node, style);
          children.addAll(childrenToAdd);
        }
        if (nodeType == "span") {
          if ((node as dom.Element).className == "source") {
            addCurrentSpans();
            final childrenToAdd = specialNodeHandlers["source"]!(this, node, style);
            children.addAll(childrenToAdd);
          }
          if ((node).className == "center-text") {
            addCurrentSpans();
            final childrenToAdd = specialNodeHandlers["center-text"]!(this, node, style);
            children.addAll(childrenToAdd);
          }
        }
      }
    }

    addCurrentSpans();

    return children;
  }
}
