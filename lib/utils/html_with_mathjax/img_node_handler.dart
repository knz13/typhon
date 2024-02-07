import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:photo_view/photo_view.dart';
import 'package:typhon/features/global_widgets/typhon_button_widget.dart';

import '../../config/size_config.dart';
import 'html_with_mathjax.dart';
import 'node_handler.dart';

class ImgNodeHandler extends SpecialNodeHandler {
  ImgNodeHandler(HtmlWithMathJaxView view, dom.Element node, TextStyle style) : super(view, node, style);

  @override
  List<Widget> handle() {
    String? src = node!.attributes['src'];
    String? widthAttr = node!.attributes['width'];
    String? heightAttr = node!.attributes['height'];

    double? width, height;

    try {
      if (widthAttr != null) {
        if (widthAttr.endsWith('%')) {
          width = double.parse(widthAttr.substring(0, widthAttr.length - 1));
        } else {
          width = double.parse(widthAttr);
        }
      }

      if (heightAttr != null) {
        if (heightAttr.endsWith('%')) {
          height = double.parse(heightAttr.substring(0, heightAttr.length - 1));
        } else {
          height = double.parse(heightAttr);
        }
      }
    } on FormatException {
      return [ErrorWidget('Cannot parse width or height')];
    }

    return [
      LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          double? w, h;

          if (width != null) {
            if (widthAttr!.endsWith('%')) {
              w = constraints.maxWidth * width / 100;
            } else {
              w = width;
            }
          }

          if (height != null) {
            if (heightAttr!.endsWith('%')) {
              h = constraints.maxHeight * height / 100;
            } else {
              h = height;
            }
          }

          return src == null
              ? Container()
              : InkWell(
                  onTap: !view.clickToViewImageCloser
                      ? null
                      : () {
                          showDialog(
                            context: context,
                            useSafeArea: false,
                            barrierColor: Colors.black.withAlpha(100),
                            builder: (context) => Stack(
                              children: [
                                PhotoView(
                                  backgroundDecoration: const BoxDecoration(color: Colors.transparent),
                                  imageProvider: Image.network(
                                    src,
                                  ).image,
                                  enablePanAlways: true,
                                  initialScale: 1,
                                ),
                                Positioned(
                                    right: getProportionateScreenWidth(50),
                                    bottom: getProportionateScreenHeight(100),
                                    child: SizedBox(
                                      width: MediaQuery.of(context).size.width * 0.3,
                                      height: getProportionateScreenHeight(40),
                                      child: TyphonButtonWidget(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text(
                                          "OK",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    )),
                              ],
                            ),
                          );
                        },
                  child: Image.network(
                    src,
                    fit: BoxFit.fill,
                    width: (view.overrideImgWidth != null
                        ? view.overrideImgWidth! * HtmlWithMathJaxView.globalImageWidthMultiplier
                        : (w != null ? w * HtmlWithMathJaxView.globalImageWidthMultiplier : null)),
                    height: view.overrideImgWidth != null ? null : h,
                    errorBuilder: (context, error,stacktrace) => ErrorWidget(
                      error,
                    ),
                  ),
                );
        },
      ),
    ];
  }
}
