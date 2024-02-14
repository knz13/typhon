import 'package:flutter/material.dart';
import 'package:typhon/config/theme.dart';

import '../config/size_config.dart';

class TopBackButton extends StatefulWidget {
  const TopBackButton({super.key, required this.onPressed});

  final void Function() onPressed;

  @override
  State<TopBackButton> createState() => _TopBackButtonState();
}

class _TopBackButtonState extends State<TopBackButton> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: getProportionateScreenWidth(25),
        child: MaterialButton(
            highlightElevation: 0,
            height: getProportionateScreenWidth(25),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: ConfigColors.nightBlack),
            ),
            splashColor: Colors.transparent,
            color: ConfigColors.platinumGray,
            elevation: 0,
            onPressed: widget.onPressed,
            child: const Icon(
              Icons.arrow_back_ios_new,
              color: ConfigColors.nightBlack,
            )),
      ),
    );
  }
}
