





import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:async';
import 'package:ffi/ffi.dart';
import 'package:flame/flame.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter/services.dart' show ByteData, Clipboard, ClipboardData, rootBundle;
import 'package:flutter/src/services/keyboard_key.g.dart';
import 'package:path/path.dart' as path;
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:path_provider/path_provider.dart';
import 'package:typhon/general_widgets.dart';
import 'package:typhon/typhon_bindings.dart';
import 'package:typhon/typhon_bindings_generated.dart';

import 'game_object.dart';




class Engine extends FlameGame with KeyboardEvents, TapDetector, MouseMovementDetector {

  static Random rng = Random();
  static Engine instance = Engine();
  static Map<int,GameObject> aliveObjects = {};


  static int generateRandomID() {
    return Engine.rng.nextInt(1 << 32);
  }

  static List<GameObject> getChildren() {
    return instance.children.whereType<GameObject>().toList();
  }

  bool isInitialized = false;

  @override
  void onMouseMove(PointerHoverInfo info) {
    // TODO: implement onMouseMove

    getCppFunctions().onMouseMove(info.eventPosition.game.x, info.eventPosition.game.y);

    super.onMouseMove(info);
  }

  @override
  KeyEventResult onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {

    keysPressed.forEach((element) {
      
      getCppFunctions().onKeyboardKeyDown(element.keyId);
    });

    return super.onKeyEvent(event, keysPressed);
  } 


  @override
  void onChildrenChanged(Component child, ChildrenChangeType type) {
    print("children changed!");
    childrenChangedNotifier.value++;


    super.onChildrenChanged(child, type);
  }



  static ValueNotifier getChildrenChangedNotifier() {
    return instance.childrenChangedNotifier;
  }

  ValueNotifier childrenChangedNotifier = ValueNotifier(0);

  @override
  FutureOr<void> onLoad() {

    if(!isInitialized){
      print("initializing engine!");

      initializeLibraryAndGetBindings().then((library) {
        library.initializeCppLibrary();
        GameObject.initializeWithCppLibrary(library);
        
      });

      isInitialized = true;
    }
    
    return super.onLoad();
  }



  @override
  void onRemove() {

    
    /* aliveObjects.forEach((key, value) { 
      GameObject.removeGameObject(key);
    });
 */


    super.onRemove();
  }

  

}