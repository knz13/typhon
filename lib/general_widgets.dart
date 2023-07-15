



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

MethodChannel contextMenuChannel = const MethodChannel('context_menu');

int _callbackId = 0;
Map<int, Function> _callbackMap = {};

Future<dynamic> _handleCallback(MethodCall methodCall) async {
  if(Platform.isWindows){
    if(methodCall.arguments is int){
      int callbackId = methodCall.arguments;
      if (_callbackMap.containsKey(callbackId)) {
        _callbackMap[callbackId]!();
      }
    }
    
  }
  else{

    int callbackId = methodCall.arguments['callbackId'];
    if (_callbackMap.containsKey(callbackId)) {
      _callbackMap[callbackId]!();
    }
  }
}

class ContextMenuOption {
  final String title;
  final void Function()? callback;
  final List<ContextMenuOption>? subOptions;
  final bool enabled;
  final String type;
  final bool selectable;

  ContextMenuOption({
    required this.title,
    this.callback,
    this.subOptions,
    this.enabled = true,
    this.selectable = false,
    this.type = "General"
  });

  
}

class ContextMenuSeparator extends ContextMenuOption {
  ContextMenuSeparator() : super(title: "",type: "Separator");
}

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
      fit: BoxFit.scaleDown,
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


void showNativeContextMenu(BuildContext context,double x,double y, List<ContextMenuOption> options) {
  if(Platform.isMacOS){
    contextMenuChannel.invokeMethod('showContextMenu', buildJSONNativeMessage(options, x,MediaQuery.of(context).size.height - y));
  }
  else if(Platform.isWindows){
    contextMenuChannel.invokeMethod('showContextMenu', buildJSONNativeMessage(options, x,y));
  }
  else{
    showContextMenu(
      ShowMenuArgs(
        MediaQuery.of(context).devicePixelRatio, 
        Offset(x,y),
       getMenuItemFromContextMenuOption(options) 
      )
    );
  }
}

List<MenuItem> getMenuItemFromContextMenuOption(List<ContextMenuOption> options) {
  return  options.map((e) => MenuItem(
          title: e.title,
          onSelected: e.callback,
          items: e.subOptions != null ? getMenuItemFromContextMenuOption(e.subOptions!) : []
        )).toList();
}

List<Map<String,dynamic>> buildOptionList(List<ContextMenuOption> options) {
  return options.map((e) {
    // ignore: unnecessary_cast
    var map =  {
      "title":e.title,
      "type":e.type,
      "enabled":e.enabled ? 1 : 0
    } as Map<String,dynamic>;

    if(map["enabled"] == 0){
      return map;
    }

    if(e.callback != null) {
      int callbackId = ++_callbackId;
      _callbackMap[callbackId] = e.callback!;
      map["callbackId"] = json.encode(callbackId);
    }
    else if(e.subOptions != null){
      map["subOptions"] = jsonEncode(buildOptionList(e.subOptions!));
    }

    return map;
  }).toList();
}

String buildJSONNativeMessage(List<ContextMenuOption> options, double x, double y) {
  List<Map<String, dynamic>> optionMaps = buildOptionList(options);

  return jsonEncode({'x': x, 'y': y, 'options': optionMaps});
}

void initializeContextMenu() {

  contextMenuChannel.setMethodCallHandler(_handleCallback);
}

class NativeContextMenuButton extends StatefulWidget {
  NativeContextMenuButton({
    required this.child,
    required this.menuItems,
    Key? key,
    this.menuOffset = Offset.zero,
    this.color
  }) : super(key: key);

  final Widget child;
  Color? color;
  final List<ContextMenuOption> menuItems;
  final Offset menuOffset;

  @override
  State<NativeContextMenuButton> createState() => _NativeContextMenuButtonState();
}

class _NativeContextMenuButtonState extends State<NativeContextMenuButton> {
  bool shouldReact = false;

  Offset mousePos = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (ev) {
        mousePos = ev.position;
      },
      child: MaterialButton(
        color: widget.color,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Theme.of(context).highlightColor,
        animationDuration: Duration.zero,
        onPressed: () {
          showNativeContextMenu(context, mousePos.dx, mousePos.dy, widget.menuItems);
        },
        minWidth: 0,
        padding: EdgeInsets.zero,
        child: widget.child
      )
    );
  }
}


class WidgetPanel {
  EngineSubWindowData subWindowData() {
    return EngineSubWindowData(child: Container(), title: "Generic window");
  }
}