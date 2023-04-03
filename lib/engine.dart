





import 'dart:async';
import 'dart:collection';
import 'dart:ffi';
import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';
import 'package:ffi/ffi.dart';
import 'package:flame/flame.dart';
import 'package:flame/image_composition.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart' hide Image;
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


class EngineRenderingDataFromAtlas {
  int width;
  int height;
  Vector2 position;
  int imageX;
  int imageY;
  double anchorX;
  double anchorY;
  double scale;
  double angle;

  EngineRenderingDataFromAtlas({
    required this.width,
    required this.height,
    required this.position,
    required this.imageX,
    required this.imageY,
    required this.anchorX,
    required this.anchorY,
    required this.scale,
    required this.angle
  });
}



class Engine extends FlameGame with KeyboardEvents, TapDetector, MouseMovementDetector {

  static Random rng = Random();
  static Engine instance = Engine();


  
  Image? atlasImage;
  static Queue<EngineRenderingDataFromAtlas> renderingObjects = Queue();

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

  static void enqueueRender(double x,double y, int width,int height, int imageX, int imageY,double anchorX,double anchorY,double scale,double angle) {
    
    renderingObjects.add(EngineRenderingDataFromAtlas(
      width: width,
      height: height,
      position: Vector2(x,y),
      imageX: imageX,
      imageY: imageY,
      anchorX: anchorX,
      anchorY: anchorX,
      scale: scale,
      angle: angle
    ));
  }

  @override
  FutureOr<void> onLoad() {

    if(!isInitialized){
      print("initializing engine!");

      initializeLibraryAndGetBindings().then((library) async {
        await extractImagesFromAssets();
        library.passProjectPath((await getApplicationDocumentsDirectory()).path.toNativeUtf8().cast());
        library.attachEnqueueRender(Pointer.fromFunction(enqueueRender));
        library.initializeCppLibrary();
        await Future.delayed(Duration(milliseconds: 500));
        File atlasImageFile = File(path.join((await getApplicationDocumentsDirectory()).path,"Typhon","lib","texture_atlas","atlas0.png"));
        if(!atlasImageFile.existsSync()){
          print("could not load atlas image!");
        }
        else {
          
          Uint8List bytes = await atlasImageFile.readAsBytes();
          atlasImage = (await (await instantiateImageCodec(bytes)).getNextFrame()).image;
          print("loaded atlas image!");
        }
      });

      isInitialized = true;
    }
    
    return super.onLoad();
  }

  @override
  void render(Canvas canvas) {
    // TODO: implement render
    super.render(canvas);

    if(atlasImage != null){
      canvas.drawAtlas(
          atlasImage!, 
          renderingObjects.map((e) => 
            RSTransform.fromComponents(
              translateX: e.position.x,
              translateY: e.position.y,
              rotation: e.angle,
              anchorX: e.anchorX,
              anchorY: e.anchorY,
              scale: e.scale
            )).toList(),
          renderingObjects.map((e) => Rect.fromLTWH(
            e.imageX.toDouble(),
            e.imageY.toDouble(), 
            e.width.toDouble(), 
            e.height.toDouble())).toList(),null,null,null,Paint());
      renderingObjects.clear();
    }

  }
  
  @override
  void update(double dt) {
    super.update(dt);

    getCppFunctions().onUpdateCall(dt);

  }

}