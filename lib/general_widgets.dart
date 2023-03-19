



import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart' show MethodCall, MethodChannel;
import 'package:flutter/widgets.dart' show Offset;
import 'package:typhon/engine_sub_window.dart';





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

void showContextMenu(double x,double y, List<ContextMenuOption> options) {
  if (Platform.isWindows && !kIsWeb) {
    // Windows-specific code
  
    // Use Win32 API to create and display a native context menu
    // See https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-trackpopupmenuex
  } else {
    // Non-Windows platforms or web
    // Use the default channel to display the context menu
    contextMenuChannel.invokeMethod('showContextMenu', buildOptionMap(options, x, y));
  }
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

class ContextMenuButton extends StatefulWidget {
  const ContextMenuButton({
    required this.child,
    required this.menuItems,
    Key? key,
    this.menuOffset = Offset.zero,
  }) : super(key: key);

  final Widget child;
  final List<ContextMenuOption> menuItems;
  final Offset menuOffset;

  @override
  State<ContextMenuButton> createState() => _ContextMenuButtonState();
}

class _ContextMenuButtonState extends State<ContextMenuButton> {
  bool shouldReact = false;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (e) {
        shouldReact = e.kind == PointerDeviceKind.mouse &&
            e.buttons == kPrimaryMouseButton;
      },
      onPointerUp: (e) async {
        if (!shouldReact) return;

        shouldReact = false;

        final position = Offset(
          
          (e.position.dx + widget.menuOffset.dx),
          MediaQuery.of(context).size.height - (e.position.dy + widget.menuOffset.dy),
        );

        showContextMenu(
          position.dx,
          position.dy,
          widget.menuItems
        );
      },
      child: widget.child,
    );
  }
}


class WidgetPanel {
  EngineSubWindowData subWindowData() {
    return EngineSubWindowData(child: Container(), title: "Generic window");
  }
}