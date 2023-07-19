import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:native_context_menu/native_context_menu.dart';

MethodChannel contextMenuChannel = const MethodChannel('context_menu');

int _callbackId = 0;
Map<int, Function> _callbackMap = {};

Future<dynamic> _handleCallback(MethodCall methodCall) async {
  if (Platform.isWindows) {
    if (methodCall.arguments is int) {
      int callbackId = methodCall.arguments;
      if (_callbackMap.containsKey(callbackId)) {
        _callbackMap[callbackId]!();
      }
    }
  } else {
    int callbackId = methodCall.arguments['callbackId'];
    print("calling callback!");
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

  ContextMenuOption(
      {required this.title,
      this.callback,
      this.subOptions,
      this.enabled = true,
      this.selectable = false,
      this.type = "General"});
}

class ContextMenuSeparator extends ContextMenuOption {
  ContextMenuSeparator() : super(title: "", type: "Separator");
}

void showNativeContextMenu(
    BuildContext context, double x, double y, List<ContextMenuOption> options) {
  if (Platform.isMacOS) {
    contextMenuChannel.invokeMethod(
        'showContextMenu',
        buildJSONNativeMessage(
            options, x, MediaQuery.of(context).size.height - y));
  } else if (Platform.isWindows) {
    contextMenuChannel.invokeMethod(
        'showContextMenu', buildJSONNativeMessage(options, x, y));
  } else {
    showContextMenu(ShowMenuArgs(MediaQuery.of(context).devicePixelRatio,
        Offset(x, y), getMenuItemFromContextMenuOption(options)));
  }
}

List<MenuItem> getMenuItemFromContextMenuOption(
    List<ContextMenuOption> options) {
  return options
      .map((e) => MenuItem(
          title: e.title,
          onSelected: e.callback,
          items: e.subOptions != null
              ? getMenuItemFromContextMenuOption(e.subOptions!)
              : []))
      .toList();
}

List<Map<String, dynamic>> buildOptionList(List<ContextMenuOption> options) {
  return options.map((e) {
    // ignore: unnecessary_cast
    var map = {"title": e.title, "type": e.type, "enabled": e.enabled ? 1 : 0}
        as Map<String, dynamic>;

    if (map["enabled"] == 0) {
      return map;
    }

    if (e.callback != null) {
      int callbackId = ++_callbackId;
      _callbackMap[callbackId] = e.callback!;
      map["callbackId"] = json.encode(callbackId);
    } else if (e.subOptions != null) {
      map["subOptions"] = jsonEncode(buildOptionList(e.subOptions!));
    }

    return map;
  }).toList();
}

String buildJSONNativeMessage(
    List<ContextMenuOption> options, double x, double y) {
  List<Map<String, dynamic>> optionMaps = buildOptionList(options);

  return jsonEncode({'x': x, 'y': y, 'options': optionMaps});
}

void initializeContextMenu() {
  contextMenuChannel.setMethodCallHandler(_handleCallback);
}
