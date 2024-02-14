



import 'dart:ffi';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart' show MethodCall, MethodChannel;
import 'package:flutter/widgets.dart' show Offset;
import 'package:native_context_menu/native_context_menu.dart';
import 'package:typhon/engine_sub_window.dart';
import 'package:typhon/main.dart';





class ReassembleListener extends StatefulWidget {
  const ReassembleListener({Key? key, required this.onReassemble,required  this.child})
      : super(key: key);

  final VoidCallback onReassemble;
  final Widget child;

  @override
  _ReassembleListenerState createState() => _ReassembleListenerState();
}

class _ReassembleListenerState extends State<ReassembleListener> {
  @override
  void reassemble() {
    super.reassemble();
    widget.onReassemble();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

T? castOrNull<T>(dynamic x) => x is T ? x : null;

Color nightBlack = Color(0xff100F0F);
Color jetBlack = Color(0xff303036);
Color platinumGray = Color(0xffD8D5DB);
Color midGray = Color.fromARGB(255, 60, 60, 60);


class GeneralButton extends StatelessWidget {

  GeneralButton({
    required this.onPressed,
    this.child,
    this.color,
    this.needsHoverColor = true
  });

  void Function() onPressed;
  Widget? child;
  Color? color;
  bool needsHoverColor;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return FittedBox(
      fit: BoxFit.contain,
      child: MaterialButton(
        minWidth: 0,
        padding: EdgeInsets.zero,
        splashColor: Colors.transparent,
        hoverColor: needsHoverColor ? Colors.white24 : Colors.transparent,
        highlightColor: Colors.white24,
        color: color,
        onPressed: onPressed,
        child: child,
      ),
    );
  }

}



class GeneralText extends StatelessWidget {


  String text;
  double fontSize;
  Color? color;
  TextOverflow? overflow;
  TextAlign? alignment;

  GeneralText(this.text,{super.key,this.fontSize = 14,this.color,this.overflow,this.alignment});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Text(
      text,
      textAlign: alignment,
      style: TextStyle(
        overflow: overflow ?? TextOverflow.ellipsis,
        color: color ?? platinumGray,
        fontSize: fontSize,
        
      ),
    );
  }
}


Future<bool> isCommandInstalled(String command) async {
  try {
    // Run the command with the "--version" option to check if it is installed
    final result = await Process.run(command, ['--version']);
    return result.exitCode == 0;
  } on ProcessException {
    // If the command is not found, return false
    return false;
  }
}





class WidgetPanel {
  EngineSubWindowData subWindowData() {
    return EngineSubWindowData(child: Container(), title: "Generic window");
  }
}