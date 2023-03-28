




import 'dart:async';
import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:flame/cache.dart';
import 'package:flame/components.dart';
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
    Engine.instance!.add(obj);
    obj.positionXPointer = malloc.allocate(64);
    obj.positionYPointer = malloc.allocate(64);
    obj.scaleXPointer = malloc.allocate(64);
    obj.scaleYPointer = malloc.allocate(64);
    obj.positionXPointer!.value = obj.position.x;
    obj.positionYPointer!.value = obj.position.y;
    obj.scaleXPointer!.value = obj.scale.x;
    obj.scaleYPointer!.value = obj.scale.y;
    Engine.instance!.childrenChangedNotifier.value++;
    Engine.aliveObjects[id] = obj;

  
    
    return id;
  }

  static void attachPointersToObject(int id){
    GameObject obj = Engine.aliveObjects[id]!;
    getCppFunctions().attachPositionPointersToGameObject(id,obj.positionXPointer!,obj.positionYPointer!);
    getCppFunctions().attachScalePointerToGameObject(id,obj.scaleXPointer!,obj.scaleYPointer!);
  }

  static void removeGameObject(int id) {
    onDeleteFunction(id);
    Engine.instance!.remove(Engine.aliveObjects[id]!);
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
    super.onRemove();

    malloc.free(positionXPointer!);
    malloc.free(positionYPointer!);
    malloc.free(scaleXPointer!);
    malloc.free(scaleYPointer!);
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

    positionXPointer!.value = position.x;
    positionYPointer!.value = position.y;
    scaleXPointer!.value = scale.x;
    scaleYPointer!.value = scale.y;
    

    GameObject.onPreDrawFunction(identifier);
    _sprite?.render(canvas,position: position,size: Vector2(width,height),overridePaint: paint);
    GameObject.onPostDrawFunction(identifier);
  }




}