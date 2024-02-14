import 'package:flutter/material.dart';

import '../../config/size_config.dart';
import '../../utils/html_with_mathjax/html_with_mathjax.dart';

class TyphonErrorPage extends StatelessWidget {
  final Widget child;
  final String? errorText;

  const TyphonErrorPage(
      {super.key,
      required this.child,
      required this.errorText,});

  @override
  Widget build(BuildContext context) {
    return errorText != null
        ? SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(12)),
              child: Column(
                children: [
                 
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(10)),
                      child: HtmlWithMathJaxView(
                        code: errorText!,
                        style: TextStyle(fontSize: getProportionateFontSize(20)),
                      ),
                    ),
                 
                ],
              ),
            ),
          )
        : child;
  }
}
