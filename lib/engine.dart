





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


class LuaGameObject extends PositionComponent {



}




int addGameObject(int parent) {
  int id = Engine.generateRandomID();


  while(Engine.registeredLuaGameObjects.containsKey(id) && id == -1){
    id = Engine.generateRandomID();
  }

  LuaGameObject component = LuaGameObject();
  Engine.registeredLuaGameObjects[id] = component;


  if(parent != -1 && Engine.registeredLuaGameObjects.containsKey(parent)){
    Engine.registeredLuaGameObjects[id]!.add(component);
  }
  else {
    Engine.addLuaGameObject(component);
  }


  return id;
}

bool checkIfIDValid(int componentID) {
  if(!Engine.registeredLuaGameObjects.containsKey(componentID)) {
    return false;
  }
  return true;
}



int removeGameObject(int componentID){

  if(!checkIfIDValid(componentID)){
    return 0;
  }

  Component current = Engine.registeredLuaGameObjects[componentID]!;

  current.removeFromParent();

  Engine.registeredLuaGameObjects.remove(componentID);

  return 1;
}



class Engine extends FlameGame {

  static Map<int,LuaGameObject> registeredLuaGameObjects = {};
  static Random rng = Random();
  static Engine? instance;


  static int generateRandomID() {
    return Engine.rng.nextInt(1 << 32);
  }


  static void addLuaGameObject(LuaGameObject component) {
    Engine.instance?.add(component);
  }

  static void printToConsoleWindow(Pointer<Char> ptr){
    String s = ptr.cast<Utf8>().toDartString();

    print(s);
  }
  

  @override
  FutureOr<void> onLoad() {

    initializeLibraryAndGetBindings().then((library) {
      //Registering main functions
      library.registerAddGameObjectFunction(Pointer.fromFunction(addGameObject,0));
      library.registerPrintToEditorWindow(Pointer.fromFunction(printToConsoleWindow));

      
      loadScriptFromString("somthing!");
    });
    
    
    return super.onLoad();
  }

}