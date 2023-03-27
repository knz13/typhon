





import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:async';
import 'package:ffi/ffi.dart';
import 'package:flame/flame.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'package:flutter/src/services/keyboard_key.g.dart';
import 'package:path/path.dart' as path;
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:path_provider/path_provider.dart';
import 'package:typhon/general_widgets.dart';
import 'package:typhon/typhon_bindings.dart';
import 'package:typhon/typhon_bindings_generated.dart';

import 'game_object.dart';




class Engine extends FlameGame with KeyboardEvents, TapDetector {

  static Random rng = Random();
  static Engine? instance;
  static Map<int,GameObject> aliveObjects = {};

  static int generateRandomID() {
    return Engine.rng.nextInt(1 << 32);
  }

  static List<GameObject> getChildren() {
    return instance?.children.toList().whereType<GameObject>().toList() ?? [];
  }

  @override
  KeyEventResult onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    

    return super.onKeyEvent(event, keysPressed);
  }


  @override
  void onChildrenChanged(Component child, ChildrenChangeType type) {
    
    childrenChangedNotifier.value++;


    super.onChildrenChanged(child, type);
  }


  static ValueNotifier? getChildrenChangedNotifier() {
    return instance?.childrenChangedNotifier;
  }

  ValueNotifier childrenChangedNotifier = ValueNotifier(0);

  @override
  FutureOr<void> onLoad() {

    instance = this;

    initializeLibraryAndGetBindings().then((library) {
      library.initializeCppLibrary();
      GameObject.initializeWithCppLibrary(library);
      
    });
    


    
    return super.onLoad();
  }

  @override
  void onRemove() {

    aliveObjects.forEach((key, value) { 
      GameObject.removeGameObject(key);
    });



    super.onRemove();
  }

}