



import 'dart:async';
import 'dart:ui';

import 'package:flame/cache.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:typhon/game_object.dart';

class NPC extends GameObject {


  NPC({required super.name});


  Paint paint = Paint()..color = Colors.white ..style = PaintingStyle.fill;
  Images images = Images();
  Sprite? _sprite;

  @override
  FutureOr<void> onLoad() async {
    // TODO: implement onLoad


    anchor = Anchor.center;
    await setDefaults(this);

    

    return super.onLoad();
  }

  Sprite? findFrame(int frameHeight) {
    return _sprite;
  }




  Future<void> setDefaults(NPC npc) async {
    
  }

  void cloneDefaults(NPC npc){
    npc.setDefaults(this);
  }



  void aI() {

  }

  void preDraw() {

  }

  void postDraw() {

  }

  @override
  void render(Canvas canvas) {
    // TODO: implement render
    super.render(canvas);

    preDraw();
    _sprite?.render(canvas,position: position,size: Vector2(width,height),overridePaint: paint);
    postDraw();
  }



}