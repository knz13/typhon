





import 'dart:async';
import 'dart:collection';
import 'dart:convert';
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

import 'file_viewer_panel.dart';


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
  

  String projectPath = "";
  String projectName = "";
  Image? atlasImage;
  static Queue<EngineRenderingDataFromAtlas> renderingObjects = Queue();

  bool isInitialized = false;


  Future<Map<String,dynamic>> getProjectsJSON() async {
    Directory privateDir = await getApplicationSupportDirectory();
    File projectsFile = File(path.join(privateDir.path,"Typhon","projects.json"));
    if(projectsFile.existsSync()){
      String fileData = projectsFile.readAsStringSync();
      var map = jsonDecode(fileData);
      return map;
    }
    else {
      projectsFile.writeAsStringSync("{}");
      
      return <String,dynamic>{};
    }
  }

  Future<void> saveProjectsJSON(Map<String,dynamic> projects) async {
    Directory privateDir = await getApplicationSupportDirectory();
    File projectsFile = File(path.join(privateDir.path,"Typhon","projects.json"));
    projectsFile.writeAsStringSync(jsonEncode(projects));
  } 


  Future<void> initializeProject(String projectPath,String projectName) async {
    
    //testing if project exists and loading it if true
    var map = await getProjectsJSON();

    if(map.containsKey(projectPath)) {
      this.projectPath = projectPath;
      this.projectName = projectName;

      FileViewerPanel.leftInitialDirectory.value = Directory(projectPath);
      FileViewerPanel.currentDirectory.value = Directory(path.join(projectPath,"assets"));

      String cmakeFileData = "";
      File cmakeFile = File(path.join(projectPath,"CMakeLists.txt"));
      List<String> lines = cmakeFile.readAsLinesSync();
      for(String line in lines) {
        if(line.contains("__TYPHON__LIBRARY_LOCATION__LINE__")){
          cmakeFileData += "link_directories(${await TyphonCPPInterface.getLibraryPath()}) #__TYPHON__LIBRARY_LOCATION__LINE__";
          continue;
        }
        cmakeFileData += line;
      }

      await cmakeFile.writeAsString(cmakeFileData);

      if(TyphonCPPInterface.checkIfLibraryLoaded()){
        TyphonCPPInterface.getCppFunctions().unloadLibrary();
      }
      var library = await TyphonCPPInterface.initializeLibraryAndGetBindings();
      await TyphonCPPInterface.extractImagesFromAssets();
      library.passProjectPath((await getApplicationSupportDirectory()).path.toNativeUtf8().cast());
      library.attachEnqueueRender(Pointer.fromFunction(enqueueRender));
      library.initializeCppLibrary();
      await Future.delayed(Duration(milliseconds: 500));
      await loadAtlasImage();

      return;

    }
    
    map[projectPath] = {
      "name":projectName
    };

    Directory documentsDir = await getApplicationSupportDirectory();

    if(!Directory(projectPath).existsSync()) {
      Directory(projectPath).createSync(recursive: true);
    }

    Directory(path.join(projectPath,"assets")).createSync(recursive: true);

    await TyphonCPPInterface.extractIncludesFromAssets(path.join(projectPath,"includes"));

    ByteData cmakeTemplateData = await rootBundle.load("assets/cmake_template.txt");
    String cmakeTemplateString = utf8.decode(cmakeTemplateData.buffer.asUint8List(cmakeTemplateData.offsetInBytes,cmakeTemplateData.lengthInBytes));



    cmakeTemplateString = cmakeTemplateString.replaceAll('__CMAKE__VERSION__','3.16')
    .replaceAll('__PROJECT__NAME__',projectName)
    .replaceAll('__TYPHON__LIBRARY__LOCATION__',await TyphonCPPInterface.getLibraryPath())
    .replaceAll('__TYPHON__INCLUDE__DIRECTORIES__',path.join(projectPath,'includes'));
    

    await File(path.join(projectPath,"CMakeLists.txt")).writeAsString(cmakeTemplateString);

    await saveProjectsJSON(map);

    return await initializeProject(projectPath, projectName);

  }

  Future<void> loadAtlasImage() async {
    File atlasImageFile = File(path.join((await getApplicationSupportDirectory()).path,"Typhon","lib","texture_atlas","atlas0.png"));
    if(!atlasImageFile.existsSync()){
      print("could not load atlas image!");
    }
    else {
      
      Uint8List bytes = await atlasImageFile.readAsBytes();
      atlasImage = (await (await instantiateImageCodec(bytes)).getNextFrame()).image;
      print("loaded atlas image!");
    }

  }

  @override
  void onMouseMove(PointerHoverInfo info) {
    // TODO: implement onMouseMove

    if(TyphonCPPInterface.checkIfLibraryLoaded()){
      TyphonCPPInterface.getCppFunctions().onMouseMove(info.eventPosition.game.x, info.eventPosition.game.y);
    }

    super.onMouseMove(info);
  }

  @override
  KeyEventResult onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
      if(TyphonCPPInterface.checkIfLibraryLoaded()){
        if(event is RawKeyDownEvent) {
          TyphonCPPInterface.getCppFunctions().onKeyboardKeyDown(event.logicalKey.keyId);
        }
        if(event is RawKeyUpEvent){
          TyphonCPPInterface.getCppFunctions().onKeyboardKeyUp(event.logicalKey.keyId);
        }
      }

    return super.onKeyEvent(event, keysPressed);
  } 

  Future<void> waitingForInitialization() async {
    while(true) {
      if(isInitialized) {
        return;
      }
      await Future.delayed(Duration(milliseconds: 100));
    }
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
  FutureOr<void> onLoad() async {

    if(!isInitialized){
      print("initializing engine!");

      //var map = (await getProjectsJSON());
      //map.clear();
      //await saveProjectsJSON(map);
      //Directory("/Users/otaviomaya/Documents/testTyphon").deleteSync(recursive: true);
      //Directory("/Users/otaviomaya/Documents/testTyphon").createSync();


      //initializeProject("/Users/otaviomaya/Documents/testTyphon", "TestTyphon");

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

    if(TyphonCPPInterface.checkIfLibraryLoaded()){
      TyphonCPPInterface.getCppFunctions().onUpdateCall(dt);
    }

  }

}