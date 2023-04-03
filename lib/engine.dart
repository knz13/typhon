





import 'dart:async';
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
  int x;
  int y;

  EngineRenderingDataFromAtlas({
    required this.width,
    required this.height,
    required this.x,
    required this.y
  });
}



class Engine extends FlameGame with KeyboardEvents, TapDetector, MouseMovementDetector {

  static Random rng = Random();
  static Engine instance = Engine();


  
  Image? atlasImage;
  List<EngineRenderingDataFromAtlas> renderingObjects = [];

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

  void updateRenderingDataFromCpp(Pointer<Pointer<Int64>> data,int numberOfItems) {
    renderingObjects.clear();

    for(int number in List.generate(numberOfItems, (index) => index)) {
      renderingObjects.add(EngineRenderingDataFromAtlas(
        width: data.elementAt(number).cast<Int64>().elementAt(0).value,
        height: data.elementAt(number).cast<Int64>().elementAt(1).value,
        x: data.elementAt(number).cast<Int64>().elementAt(2).value,
        y: data.elementAt(number).cast<Int64>().elementAt(3).value
      ));
    }
  }

  @override
  FutureOr<void> onLoad() {

    if(!isInitialized){
      print("initializing engine!");

      initializeLibraryAndGetBindings().then((library) async {
        await extractImagesFromAssets();
        library.passProjectPath((await getApplicationDocumentsDirectory()).path.toNativeUtf8().cast());
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
      canvas.renderAt(Vector2(100,0), (canvas) {
        canvas.rotate(radians(-45));
        canvas.drawImage(atlasImage!, Offset.zero, Paint());
      });
    }

  }
  
  @override
  void update(double dt) {
    super.update(dt);

    getCppFunctions().onUpdateCall(dt);

  }

}