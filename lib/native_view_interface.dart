

import 'dart:ffi';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart' show MethodCall, MethodChannel;
import 'package:flutter/widgets.dart' show Offset;



const MethodChannel _channel = MethodChannel("nativeWindowInterfaceChannel");



class NativeViewInterface {

  static Future<Pointer<Void>> createSubView(Rect rect) async {
     final int widgetView  = await _channel.invokeMethod("createRenderableView",json.encode({
      "x":rect.topLeft.dx,
      "y":rect.topLeft.dy,
      "width":rect.width,
      "height":rect.height
    }));

    return widgetView == -1? nullptr : Pointer<Void>.fromAddress(widgetView);
  }

  static void updateSubViewRect(Rect rect) async {
    await _channel.invokeMethod("setFrameRenderableView",json.encode({
      "x":rect.topLeft.dx,
      "y":rect.topLeft.dy,
      "width":rect.width,
      "height":rect.height
    }));
  }

  static void releaseSubView() async {
    await _channel.invokeMethod("removeRenderableView");
  }

}