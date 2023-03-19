





import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:async';
import 'package:ffi/ffi.dart';
import 'dart:math';
import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'package:path/path.dart' as path;
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:path_provider/path_provider.dart';
import 'package:typhon/typhon_bindings.dart';
import 'package:typhon/typhon_bindings_generated.dart';




class Engine extends FlameGame {

  static Random rng = Random();
  static Engine? instance;


  static int generateRandomID() {
    return Engine.rng.nextInt(1 << 32);
  }

 

  @override
  FutureOr<void> onLoad() {
    

    initializeLibraryAndGetBindings().then((library) {
        //do stuff related to lua here
    });
    


    
    return super.onLoad();
  }

}