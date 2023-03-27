




import 'dart:async';

import 'package:flame/cache.dart';
import 'package:flame/components.dart';
import 'package:flame/image_composition.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:typhon/typhon_bindings_generated.dart';


class GameObject extends PositionComponent {

  

  String name;

  GameObject({required this.name});

  static void initializeWithCppLibrary(TyphonBindings library) {
    // create all the OnEventHappenned type things
    // ex. OnUpdate(dt), OnLoad(), OnFindFrame(), OnSetDefaults()
  } 

  
  Paint paint = Paint()..color = Colors.white ..style = PaintingStyle.fill;
  Images images = Images();
  Sprite? _sprite;

  @override
  FutureOr<void> onLoad() async {
    // TODO: implement onLoad


    anchor = Anchor.center;
    setDefaultsFunc();

    

    return super.onLoad();
  }

  Sprite? findFrame(int frameHeight) {
    return _sprite;
  }

  void Function() setDefaultsFunc = () {};

  @override
  void update(double dt) {
    // TODO: implement update
    super.update(dt);

    
  }

  void Function() aiFunction = () {};
  

  void Function() preDrawFunction = () {};

  void Function() postDrawFunction = () {};



  @override
  void render(Canvas canvas) {
    super.render(canvas);

    findFrame(height.toInt());

    preDrawFunction();
    _sprite?.render(canvas,position: position,size: Vector2(width,height),overridePaint: paint);
    postDrawFunction();
  }




}