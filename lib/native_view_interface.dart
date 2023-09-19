

import 'dart:ffi';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart' show MethodCall, MethodChannel;
import 'package:flutter/widgets.dart' show Offset;



MethodChannel _channel = const MethodChannel("nativeWindowInterfaceChannel")..setMethodCallHandler((call) async {
  if(call.method == "pointerDetached") {
    print("Called pointerDetached on flutter!");
    NativeViewInterface.waitingToFinishDetaching = false;
  }
});



class NativeViewInterface {

  static var waitingToFinishDetaching = true;

  static Future<Pointer<Void>> getMetalViewPointer() async {

    return Pointer.fromAddress(await _channel.invokeMethod("getMetalViewPointer"));
  }

  static void attachCPPPointer(Pointer<Void> ptr) async {
    
    if(ptr != nullptr){
      await _channel.invokeMethod("attachCPPPointer",ptr.address);
    }
    else {
      print("Tried to attach nullptr to native view interface!");
    }
  }

  static void updateSubViewRect(Rect rect) async {
    await _channel.invokeMethod("setFrameRenderableView",json.encode({
      "x":rect.topLeft.dx,
      "y":rect.topLeft.dy,
      "width":rect.width,
      "height":rect.height
    }));
  }
  
  static Future<void> detachCPPPointer() async {
    await _channel.invokeMethod("detachCPPPointer");
    
    return Future.doWhile(() {
      print("Waiting!");
      return waitingToFinishDetaching;
    })..then((value) {
      print("finished waiting to finish detaching!");
      NativeViewInterface.waitingToFinishDetaching = true;
    });
  }

}