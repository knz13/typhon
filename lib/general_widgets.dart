



import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart' show MethodCall, MethodChannel;
import 'package:flutter/widgets.dart' show Offset;
import 'package:native_context_menu/native_context_menu.dart';
import 'package:typhon/engine_sub_window.dart';



Color nightBlack = Color(0xff100F0F);
Color jetBlack = Color(0xff303036);
Color platinumGray = Color(0xffD8D5DB);

MethodChannel contextMenuChannel = const MethodChannel('context_menu');

int _callbackId = 0;
Map<int, Function> _callbackMap = {};

Future<dynamic> _handleCallback(MethodCall methodCall) async {
  int callbackId = methodCall.arguments['callbackId'];
  if (_callbackMap.containsKey(callbackId)) {
    _callbackMap[callbackId]!();
  }
}

class ContextMenuOption {
  final String title;
  final void Function()? callback;
  final List<ContextMenuOption>? subOptions;

  ContextMenuOption({
    required this.title,
    this.callback,
    this.subOptions,
  });
}

void showNativeContextMenu(BuildContext context,double x,double y, List<ContextMenuOption> options) {
  if(Platform.isMacOS){
    contextMenuChannel.invokeMethod('showContextMenu', buildOptionMap(options, x,MediaQuery.of(context).size.height - y));
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

Map<String, dynamic> buildOptionMap(List<ContextMenuOption> options, double x, double y) {
  List<Map<String, dynamic>> optionMaps = [];
  for (var option in options) {
    Map<String, dynamic> optionMap = {
      'title': option.title,
    };
    if (option.callback != null) {
      int callbackId = ++_callbackId;
      _callbackMap[callbackId] = option.callback!;
      optionMap['callbackId'] = callbackId;
    }
    if (option.subOptions != null) {
      optionMap['subOptions'] = buildOptionMap(option.subOptions!, x, y);
    }
    optionMaps.add(optionMap);
  }
  return {'x': x, 'y': y, 'options': optionMaps};
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