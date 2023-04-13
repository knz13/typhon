





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
import 'package:typhon/recompiling_dialog.dart';
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
    File projectsFile = File(path.join(privateDir.path,"projects.json"));
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
    File projectsFile = File(path.join(privateDir.path,"projects.json"));
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
    if(!TyphonCPPInterface.checkIfLibraryLoaded()){
      return;
    }
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
        if(line.contains("__LIBRARY__PROJECT__PATH__")){
          var projPath = (await TyphonCPPInterface.getLibraryPath()).replaceAll("\\","/").replaceAll(" ", "\\ ");
          cmakeFileData += "add_subdirectory($projPath ${path.join(projPath,"build").replaceAll("\\","/").replaceAll(" ", "\\ ")}) #__LIBRARY__PROJECT__PATH__";
          cmakeFileData += "\n";
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

      File bindingsFile = File(path.join(projectPath,"bindings.h"));

      await bindingsFile.writeAsString("""#pragma once
#include "includes/engine.h"
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
  FFI_PLUGIN_EXPORT bool initializeCppLibrary();
  FFI_PLUGIN_EXPORT void onMouseMove(double positionX,double positionY);
  FFI_PLUGIN_EXPORT void onKeyboardKeyDown(int64_t input);
  FFI_PLUGIN_EXPORT void onKeyboardKeyUp(int64_t input);
  FFI_PLUGIN_EXPORT void onUpdateCall(double dt);
  FFI_PLUGIN_EXPORT void passProjectPath(const char* path);
  FFI_PLUGIN_EXPORT void attachEnqueueRender(EnqueueObjectRender func);
  FFI_PLUGIN_EXPORT void unloadLibrary();
  FFI_PLUGIN_EXPORT void createObjectFromClassID(int64_t classID);
  FFI_PLUGIN_EXPORT ClassesArray getInstantiableClasses();



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
    .replaceAll('__TYPHON__LIBRARY__LOCATION__',(await TyphonCPPInterface.getLibraryPath()).replaceAll("\\", "/").replaceAll(" ", "\\ "))
    .replaceAll('__TYPHON__INCLUDE__DIRECTORIES__',path.join(projectPath,'includes'));
    

    await File(path.join(projectPath,"CMakeLists.txt")).writeAsString(cmakeTemplateString);

    
    var libPath = await TyphonCPPInterface.getLibraryPath();
    if(Platform.isWindows){
      File(path.join(projectPath,"build","${path.basenameWithoutExtension(TyphonCPPInterface.libPath)}.lib")).createSync(recursive: true);
      File(path.join(projectPath,"build","${path.basenameWithoutExtension(TyphonCPPInterface.libPath)}.dll")).createSync(recursive: true);
      File(path.join(libPath,path.basename(TyphonCPPInterface.libPath))).copySync(path.join(projectPath,"build","${path.basenameWithoutExtension(TyphonCPPInterface.libPath)}.dll"));    
      File(path.join(libPath,"${path.basenameWithoutExtension(TyphonCPPInterface.libPath)}.lib")).copySync(path.join(projectPath,"build","${path.basenameWithoutExtension(TyphonCPPInterface.libPath)}.lib"));    
    }
    else{
      File(path.join(projectPath,"build",path.basename(TyphonCPPInterface.libPath))).createSync(recursive: true);
      File(path.join(libPath,path.basename(TyphonCPPInterface.libPath))).copySync(path.join(projectPath,"build",path.basename(TyphonCPPInterface.libPath)));    
    }
    
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
    
    ValueNotifier<Process?> processNotifier = ValueNotifier(null);
    RecompilingDialog dialog = RecompilingDialog(notifier: processNotifier);

    showDialog(
      barrierDismissible: false,
      context: MyApp.globalContext.currentContext!, 
      builder:(context) {
      return dialog;
    },);

    
    if(!hasInitializedProject()){
      Navigator.of(MyApp.globalContext.currentContext!).pop();
      return;
    }
    print("recompiling...");

    //finding includes
    List<String> includes = await __findPathsToInclude(Directory(path.join(projectPath,"assets")));
    print("includes found: ${includes}");
    
    File bindingsFile = File(path.join(projectPath,"bindings.h"));
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
          if(element == "assets/entry.h" || element == "assets\\entry.h"){
            return;
          }
          bindingsGeneratedData += "    ${path.basenameWithoutExtension(element)}();\n";
        });
        continue;
      }
      bindingsGeneratedData += line;

      bindingsGeneratedData += "\n";

    }
    
    File bindingsGenerated = File(path.join(projectPath,"bindings_generated.h"));
    bindingsGenerated.createSync();
    bindingsGenerated.writeAsStringSync(bindingsGeneratedData);

     File bindingsGeneratedCPP = File(path.join(projectPath,"bindings_generated.cpp"));
    bindingsGeneratedCPP.createSync();
    bindingsGeneratedCPP.writeAsString("""#include <iostream>
#include <stdint.h>
#include "bindings_generated.h"
#include "includes/mono_manager.h"
#include "includes/shader_compiler.h"

bool initializeCppLibrary() {
    
    MonoManager::getInstance();
    ShaderCompiler::getInstance();
    
    Engine::Initialize();

    return true;    

}


void onMouseMove(double positionX, double positionY)
{
    EngineInternals::SetMousePosition(Vector2f(positionX,positionY));
}

void onKeyboardKeyDown(int64_t input)
{
    Engine::PushKeyDown(input);
}

void onKeyboardKeyUp(int64_t input)
{
    Engine::PushKeyUp(input);

}

void onUpdateCall(double dt)
{
    Engine::Update(dt);


}

void passProjectPath(const char *path)
{
    HelperStatics::projectPath = std::string(path);

}


void attachEnqueueRender(EnqueueObjectRender func)
{
    EngineInternals::enqueueRenderFunc = [=](double x,double y,int64_t width,int64_t height,int64_t imageX,int64_t imageY,double anchorX,double anchorY,double scale,double angle){
        func(x,y,width,height,imageX,imageY,anchorX,anchorY,scale,angle);
    };
}

void unloadLibrary()
{
    Engine::Unload();

}

ClassesArray getInstantiableClasses()
{
    static std::vector<int64_t> ids;
    static std::vector<const char*> names;

    ids.clear();
    names.clear();

    for(const auto& [id,name] : GameObject::GetInstantiableClassesIDsToNames()){
        names.push_back(name.c_str());
        ids.push_back(id);
    }

    std::cout << "names size = " << names.size() << std::endl;

    ClassesArray arr;

    arr.array = ids.data();
    arr.size = ids.size();
    arr.stringArray = names.data();
    arr.stringArraySize = names.size();
    return arr;
}

void createObjectFromClassID(int64_t classID)
{
    Engine::CreateNewGameObject(classID);
}
""");
  

    processNotifier.value = await Process.start("cmake", ["./","-B build"],workingDirectory: projectPath,runInShell: true);
    
    if(await processNotifier.value!.exitCode != 0){
      return;
    }
    //print((await processNotifier.value!.stderr.toList()).map((e) => String.fromCharCodes(e),));
    if(Platform.isMacOS){

      processNotifier.value = await Process.start("make",[projectFilteredName],runInShell: true,workingDirectory: path.join(projectPath,"build"));
      await processNotifier.value!.exitCode;
      //print((await processNotifier.value!.stderr.toList()).map((e) => String.fromCharCodes(e),));
      if(await processNotifier.value!.exitCode != 0){
        return;
      }
    } 
    if(Platform.isWindows){
      processNotifier.value = await Process.start("msbuild",["${projectFilteredName}.sln","/target:${projectFilteredName}","/p:Configuration=Debug"],workingDirectory: path.join(projectPath,"build"),runInShell: true);
      await processNotifier.value!.exitCode;
      //print((await processNotifier.value!.stderr.toList()).map((e) => String.fromCharCodes(e),));
      if(await processNotifier.value!.exitCode != 0){
        return;
      }
    }

    var library = await TyphonCPPInterface.initializeLibraryAndGetBindings(path.join(projectPath,"build",
      Platform.isMacOS ? "lib${projectFilteredName}.dylib" : Platform.isWindows? "Debug/${projectFilteredName}.dll" : "" //TODO!
    ));
    onRecompileNotifier.value++;
    Navigator.of(MyApp.globalContext.currentContext!).pop();
        
    
  }

  Future<void> loadAtlasImage() async {
    File atlasImageFile = File(path.join((await getApplicationSupportDirectory()).path,"lib","texture_atlas","atlas0.png"));
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