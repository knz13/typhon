





import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:async';
import 'package:ffi/ffi.dart';
import 'package:flame/flame.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter/services.dart' show ByteData, Clipboard, ClipboardData, RawKeyDownEvent, RawKeyUpEvent, rootBundle;
import 'package:flutter/src/services/keyboard_key.g.dart';
import 'package:path/path.dart' as path;
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:path_provider/path_provider.dart';
import 'package:typhon/general_widgets.dart';
import 'package:typhon/typhon_bindings.dart';
import 'package:typhon/typhon_bindings_generated.dart';





class Engine extends FlameGame with KeyboardEvents, TapDetector, MouseMovementDetector {

  static Random rng = Random();
  static Engine instance = Engine();
  

  bool isInitialized = false;

  @override
  void onMouseMove(PointerHoverInfo info) {
    // TODO: implement onMouseMove

    getCppFunctions().onMouseMove(info.eventPosition.game.x, info.eventPosition.game.y);

    super.onMouseMove(info);
  }

  @override
  KeyEventResult onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
      if(event is RawKeyDownEvent) {
        getCppFunctions().onKeyboardKeyDown(event.logicalKey.keyId);
      }
      if(event is RawKeyUpEvent){
        getCppFunctions().onKeyboardKeyUp(event.logicalKey.keyId);
      }

    return super.onKeyEvent(event, keysPressed);
  } 

  @override
  FutureOr<void> onLoad() {

    if(!isInitialized){
      print("initializing engine!");

      initializeLibraryAndGetBindings().then((library) {
        library.initializeCppLibrary();
      });

      isInitialized = true;
    }
    
    return super.onLoad();
  }
  
  @override
  void update(double dt) {
    super.update(dt);

    getCppFunctions().onUpdateCall(dt);

  }

}