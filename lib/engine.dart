





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
import 'package:typhon/main.dart';
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
  
  ValueNotifier onRecompileNotifier = ValueNotifier(0);
  String projectPath = "";
  String projectName = "";
  String projectFilteredName = "";
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

  bool hasInitializedProject() {
    return projectName != "" && projectPath != "";
  }

  Future<void> reloadProject() async {
    if(TyphonCPPInterface.checkIfLibraryLoaded()){

      TyphonCPPInterface.getCppFunctions().unloadLibrary();

    }
    
    await recompileProject();
    var library = TyphonCPPInterface.getCppFunctions();
    await TyphonCPPInterface.extractImagesFromAssets();
    library.passProjectPath((await getApplicationSupportDirectory()).path.toNativeUtf8().cast());
    library.attachEnqueueRender(Pointer.fromFunction(enqueueRender));
    library.initializeCppLibrary();
    await Future.delayed(Duration(milliseconds: 500));
    await loadAtlasImage();
  }

  void unload() {
    if(TyphonCPPInterface.checkIfLibraryLoaded()){
      TyphonCPPInterface.getCppFunctions().unloadLibrary();
    }
  }

  Future<void> initializeProject(String projectDirectoryPath,String projectName) async {
    
    //testing if project exists and loading it if true
    var map = await getProjectsJSON();
    var projectFilteredName = projectName.replaceAllMapped(RegExp(r'[^a-zA-Z0-9]'), (match) => '_');
    var projectPath = path.join(projectDirectoryPath,projectFilteredName);

    
    if(map.containsKey(projectPath)) {
      this.projectPath = projectPath;
      this.projectName = projectName;
      this.projectFilteredName = projectFilteredName;
      
      String cmakeFileData = "";
      File cmakeFile = File(path.join(projectPath,"CMakeLists.txt"));
      List<String> lines = cmakeFile.readAsLinesSync();
      for(String line in lines) {
        if(line.contains("__TYPHON__LIBRARY_LOCATION__LINE__")){
          cmakeFileData += "link_directories(${(await TyphonCPPInterface.getLibraryPath()).replaceAll(r" ", r"\ ")}) #__TYPHON__LIBRARY_LOCATION__LINE__\n";
          continue;
        }
        cmakeFileData += line;
        cmakeFileData += "\n";
      }

      await cmakeFile.writeAsString(cmakeFileData);

      File entryFile = File(path.join(projectPath,"assets","entry.h"));

      await entryFile.writeAsString("""#pragma once

class Entry {
public:
  /*
  * This function will be called once when your project is created (the start of the game basically)
  * 
  * Use it to initialize anything you wish here
  */

  static void OnInitializeProject() {

  };
};
""");

      File bindingsFile = File(path.join(projectPath,"bindings.cpp"));

      await bindingsFile.writeAsString("""#include "includes/engine.h"
#include "assets/entry.h"
//__INCLUDE__USER__DEFINED__CLASSES__

#if _WIN32
#include <windows.h>
#else
#include <pthread.h>
#include <unistd.h>
#endif

#if _WIN32
#define FFI_PLUGIN_EXPORT __declspec(dllexport)
#else
#define FFI_PLUGIN_EXPORT
#endif


#ifdef __cplusplus
extern "C" {
#endif

  FFI_PLUGIN_EXPORT void onInitializeProject() {
    //__INITIALIZE__USER__DEFINED__CLASSES__
    Entry::OnInitializeProject();
  };

#ifdef __cplusplus
}
#endif
""");

      FileViewerPanel.leftInitialDirectory.value = Directory(projectPath);
      FileViewerPanel.currentDirectory.value = Directory(path.join(projectPath,"assets"));


      await reloadProject();

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
    .replaceAll('__PROJECT__NAME__',projectFilteredName)
    .replaceAll('__TYPHON__LIBRARY__LOCATION__',await TyphonCPPInterface.getLibraryPath())
    .replaceAll('__TYPHON__INCLUDE__DIRECTORIES__',path.join(projectPath,'includes'));
    

    await File(path.join(projectPath,"CMakeLists.txt")).writeAsString(cmakeTemplateString);

    await saveProjectsJSON(map);

    return await initializeProject(projectDirectoryPath, projectName);

  }

  Future<List<String>> __findPathsToInclude(Directory directory) async {
    List<String> paths = [];
    for(var maybeFile in await directory.list().toList()){
      print(path.basename(maybeFile.path));
      if(maybeFile is File && maybeFile.path.substring(maybeFile.path.lastIndexOf(".")) == ".h") {
        paths.add(path.relative(maybeFile.path,from:projectPath));
      }
      if(maybeFile is Directory){
        __findPathsToInclude(maybeFile);
      }
    } 
    return paths;

  }

  Future<void> recompileProject() async {
    

    showDialog(context: MyApp.globalContext.currentContext!, builder:(context) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          backgroundColor: Colors.blue,
          child: Column(
            children: [
              GeneralText("Recompiling..."),
              CircularProgressIndicator()
            ],
          ),
        )
    );
    },);
    if(!hasInitializedProject()){
      Navigator.of(MyApp.globalContext.currentContext!).pop();
      return;
    }
    print("recompiling...");

    //finding includes
    List<String> includes = await __findPathsToInclude(Directory(path.join(projectPath,"assets")));
    print("includes found: ${includes}");
    
    File bindingsFile = File(path.join(projectPath,"bindings.cpp"));
    String bindingsGeneratedData = "";
    List<String> lines = bindingsFile.readAsLinesSync();
    for(String line in lines) {
      
      if(line.contains("//__INCLUDE__USER__DEFINED__CLASSES__")){
        includes.forEach((element) { 
          if(element == "assets/entry.h"){
            return;
          }
          bindingsGeneratedData += '#include "${element}"\n';
        });
        continue;
      }
      if(line.contains("//__INITIALIZE__USER__DEFINED__CLASSES__")){
        includes.forEach((element) {
          if(element == "assets/entry.h"){
            return;
          }
          bindingsGeneratedData += "    ${path.basenameWithoutExtension(element)}();\n";
        });
        continue;
      }
      bindingsGeneratedData += line;

      bindingsGeneratedData += "\n";

    }
    
    File bindingsGenerated = File(path.join(projectPath,"bindings_generated.cpp"));
    bindingsGenerated.createSync();
    bindingsGenerated.writeAsStringSync(bindingsGeneratedData);
  

    var result = await Process.run("cmake", ["-B build"],workingDirectory: projectPath,runInShell: true);
    if(Platform.isMacOS){
      result = await Process.run("make",[projectFilteredName],runInShell: true,workingDirectory: path.join(projectPath,"build"));
      print(result.stdout);
      print(result.stderr);

    } 
    var library = await TyphonCPPInterface.initializeLibraryAndGetBindings(path.join(projectPath,"build",
      Platform.isMacOS ? "lib${projectFilteredName}.dylib" : "" //TODO!
    ));
    onRecompileNotifier.value++;
    Navigator.of(MyApp.globalContext.currentContext!).pop();
        
    
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