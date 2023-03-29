




import 'dart:async';
import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:flame/cache.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/image_composition.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:typhon/engine.dart';
import 'package:typhon/typhon_bindings.dart';
import 'package:typhon/typhon_bindings_generated.dart';


class GameObject extends PositionComponent {

  

  int identifier;

  GameObject({required this.identifier});



  static void initializeWithCppLibrary(TyphonBindings library) {
    // create all the OnEventHappenned type things
    // ex. OnUpdate(dt), OnLoad(), OnFindFrame(), OnSetDefaults(), OnAI(),OnPreDraw(), OnPostDraw()
    library.attachCreateGameObjectFunction(Pointer.fromFunction(createNewGameObject,0));
    library.attachRemoveGameObjectFunction(Pointer.fromFunction(removeGameObject));
    library.attachPointersToObject(Pointer.fromFunction(attachPointersToObject));
    library.attachAddTextureToObjectFunction(Pointer.fromFunction(loadTextureToGameObject));
    onDeleteFunction = library.attachOnRemoveObjectFunction().asFunction();
    onUpdateFunc = library.attachUpdateFunction().asFunction();
    onSetDefaultsFunc = library.attachSetDefaultsFunction().asFunction();
    onPreDrawFunction = library.attachPreDrawFunction().asFunction();
    onPostDrawFunction = library.attachPostDrawFunction().asFunction();
  } 


  static void Function(int) onSetDefaultsFunc = (v) {};
  static void Function(int,double) onUpdateFunc = (v,dt) {};
  static void Function(int) onPreDrawFunction = (v) {};
  static void Function(int) onPostDrawFunction = (v) {};
  static void Function(int) onDeleteFunction = (v) {};
  static int createNewGameObject() {
    int id = Engine.generateRandomID();

    GameObject obj = GameObject(identifier: id);
    Engine.instance.add(obj);
    obj.positionXPointer = malloc.allocate(64);
    obj.positionYPointer = malloc.allocate(64);
    obj.scaleXPointer = malloc.allocate(64);
    obj.scaleYPointer = malloc.allocate(64);
    obj.positionXPointer!.value = obj.position.x;
    obj.positionYPointer!.value = obj.position.y;
    obj.scaleXPointer!.value = obj.scale.x;
    obj.scaleYPointer!.value = obj.scale.y;
    Engine.aliveObjects[id] = obj;

  
    
    return id;
  }

  static void loadTextureToGameObject(int gameObjectID,Pointer<Char> value) {
    String stringValue = value.cast<Utf8>().toDartString();
    print("loading texture to object with id $gameObjectID");
    if(Engine.aliveObjects.containsKey(gameObjectID)){
      Flame.images.load(stringValue).then((value) {
        print("loaded texture to object with id $gameObjectID");
        Engine.aliveObjects[gameObjectID]!._sprite = Sprite(value);
        Engine.aliveObjects[gameObjectID]!.width = value.width.toDouble();
        Engine.aliveObjects[gameObjectID]!.height = value.height.toDouble();

      });

    }
  }

  static void attachPointersToObject(int id){
    GameObject obj = Engine.aliveObjects[id]!;
    getCppFunctions().attachPositionPointersToGameObject(id,obj.positionXPointer!,obj.positionYPointer!);
    getCppFunctions().attachScalePointerToGameObject(id,obj.scaleXPointer!,obj.scaleYPointer!);
  }

  static void removeGameObject(int id) {
    if(!Engine.aliveObjects.containsKey(id)) {
      print("trying to delete an object with an invalid id! Check if calling Engine.aliveObjects for addition");
      return;
    }

    onDeleteFunction(id);
    Engine.instance.remove(Engine.aliveObjects[id]!);
    Engine.aliveObjects.remove(id);
  }


  Pointer<Double>? positionXPointer;
  Pointer<Double>? positionYPointer;
  Pointer<Double>? scaleXPointer;
  Pointer<Double>? scaleYPointer;
  
  Paint paint = Paint()..color = Colors.white ..style = PaintingStyle.fill;
  Images images = Images();
  Sprite? _sprite;

  @override
  void onRemove() {
    // TODO: implement onRemove
    malloc.free(positionXPointer!);
    malloc.free(positionYPointer!);
    malloc.free(scaleXPointer!);
    malloc.free(scaleYPointer!);

    
    getCppFunctions().removeObjectFromObjectsBeingDeleted(identifier);
    
    super.onRemove();

  }

  //each object should be called with a specific
  @override
  FutureOr<void> onLoad() async {

    anchor = Anchor.center;

    return super.onLoad();
  }

  bool hasSetDefaults = false;

  @override
  void update(double dt) {
    super.update(dt);

    if(!hasSetDefaults){
      GameObject.onSetDefaultsFunc(identifier);
      hasSetDefaults = true;
    }
    position.x = positionXPointer!.value;
    position.y = positionYPointer!.value;
    scale.x = scaleXPointer!.value;
    scale.y = scaleYPointer!.value;
    

    GameObject.onUpdateFunc(identifier,dt);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    GameObject.onPreDrawFunction(identifier);
    _sprite?.render(canvas,position: position,size: Vector2(width,height),overridePaint: paint);
    GameObject.onPostDrawFunction(identifier);
  }




}