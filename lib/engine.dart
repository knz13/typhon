





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
import 'package:typhon/console_panel.dart';
import 'package:typhon/general_widgets.dart';
import 'package:typhon/main.dart';
import 'package:typhon/native_view_interface.dart';
import 'package:typhon/recompiling_dialog.dart';
import 'package:typhon/regex_parser.dart';
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



class Engine {

  static Random rng = Random();
  static Engine instance = Engine();
  
  ValueNotifier onRecompileNotifier = ValueNotifier(0);
  String projectPath = "";
  String projectName = "";
  String projectFilteredName = "";
  Image? atlasImage;
  bool _isProjectLoaded = false;
  bool _isReloading = false;
  bool _shouldRecompile = false;
  ValueNotifier<bool> lastCompilationResult = ValueNotifier(false);
  static Queue<EngineRenderingDataFromAtlas> renderingObjects = Queue();
  ValueNotifier<List<int>> currentChildren = ValueNotifier([]);

  bool isInitialized = false;


  void enqueueRecompilation() {
    if(hasInitializedProject()){
      _shouldRecompile = true;
      reloadProject();
    }
  }

  bool shouldRecompile() {
    return _shouldRecompile;
  }

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
    return _isProjectLoaded;
  } 

  void detachPlatformSpecificView() {
    if(TyphonCPPInterface.checkIfLibraryLoaded()){
       NativeViewInterface.detachCPPPointer();
    }
  }

  void attachPlatformSpecificView() {
    if(TyphonCPPInterface.checkIfLibraryLoaded()){
      var ptr = TyphonCPPInterface.getCppFunctions().getPlatformSpecificPointer();
      if(ptr != nullptr){
        NativeViewInterface.attachCPPPointer(ptr);
      }
    }
  }

  Future<void> reloadProject() async {
    if(_isReloading){
      return;
    }
    _isReloading = true;
    unload();

    await TyphonCPPInterface.extractImagesFromAssets(path.join(projectPath,"build","images"));
    
    await recompileProject();
    if(!TyphonCPPInterface.checkIfLibraryLoaded()){
      print("Could not load library!");
      _isReloading = false;
      return;
    }

    var library = TyphonCPPInterface.getCppFunctions();
    library.passProjectPath(projectPath.toNativeUtf8().cast());
    library.attachEnqueueRender(Pointer.fromFunction(enqueueRender));
    library.attachEnqueueOnChildrenChanged(Pointer.fromFunction(onCppChildrenChanged));
    library.initializeCppLibrary();
    var ptr = library.getPlatformSpecificPointer();
    NativeViewInterface.attachCPPPointer(ptr);
    
    (()async {
      while(true){
        if(library.isEngineInitialized() == true){
          await loadAtlasImage();
          break;
        }
        await Future.delayed(Duration(milliseconds: 100));
      }
    })();
    _isReloading = false;
    _shouldRecompile = false;
  }

  void unloadProject() {
    projectName = "";
    projectPath = "";
    projectFilteredName = "";
    _isProjectLoaded = false;
    ConsolePanel.clear();
    unload();
  }

  void unload() {
    if(currentProcess != null){
      currentProcess!.kill();
    }
    currentProcess = null;

    if(TyphonCPPInterface.checkIfLibraryLoaded()){
      NativeViewInterface.detachCPPPointer().then((value) {
        TyphonCPPInterface.getCppFunctions().unloadLibrary();
        TyphonCPPInterface.detachLibrary();
      });
    }
  }



  static void onCppChildrenChanged() {

    AliveObjectsArray arr = TyphonCPPInterface.getCppFunctions().getAliveObjects();

    Int64List list = arr.array.asTypedList(arr.size);

    Engine.instance.currentChildren.value = list.toList();


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
        if(line.contains("__TYPHON__LIBRARY__LOCATION__")){
          var projPath = (await TyphonCPPInterface.getLibraryPath()).replaceAll("\\","/").replaceAll(" ", "\\ ");
          cmakeFileData += "set(TYPHON_LIBRARY_LOCATION $projPath) #__TYPHON__LIBRARY__LOCATION__";
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

      File bindingsFile = File(path.join(projectPath,"bindings.cpp"));

      await bindingsFile.writeAsString("""
#include "bindings_generated.h"
//__BEGIN__CPP__IMPL__
#include <iostream>

#include <stdint.h>

#include "engine.h"

#include "rendering_engine.h"

//__INCLUDE__CREATED__CLASSES__



bool initializeCppLibrary() {

    

    

    //__INITIALIZE__CREATED__CLASSES__



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



void attachEnqueueOnChildrenChanged(OnChildrenChangedFunc func) {

    EngineInternals::onChildrenChangedFunc = [=](){

        func();

    };

}



void unloadLibrary()

{

    Engine::Unload();



}



AliveObjectsArray getAliveObjects() {

    static std::vector<int64_t> ids;





    ids.clear();

    auto view = Engine::View();

    ids.reserve(view.size());

    for(const auto& obj : view) {

        ids.push_back(obj->Handle());

    }





    AliveObjectsArray arr;

    arr.array = ids.data();

    arr.size = ids.size();





    return arr;



}



const char* getObjectNameByID(int64_t id) {

    static std::vector<char> temp = std::vector<char>();

    static const char* ptr = nullptr;



    temp.clear(); 



    GameObject* obj = Engine::GetObjectFromID(id);

    std::cout << "tried getting object with id: " << id << " with result ptr = "<< (void*)obj << std::endl;



    if(obj == nullptr){

        temp.push_back('\0');

        ptr = temp.data();

        return ptr;

    }

    temp.reserve(obj->Name().size() + 1);

    memcpy(temp.data(),obj->Name().c_str(),obj->Name().size() + 1);

    ptr = temp.data();





    return ptr;

};





void removeObjectByID(int64_t id) {

    if(Engine::ValidateHandle(id)){

        Engine::RemoveGameObject(id);

    }

}





const char* getObjectSerializationByID(int64_t id) {



    static std::vector<char> temp = std::vector<char>();

    static const char* ptr = nullptr;



    temp.clear(); 



    GameObject* obj = Engine::GetObjectFromID(id);

    

    if(obj == nullptr){

        temp.reserve(3);

        temp.push_back('{');

        temp.push_back('}');

        temp.push_back('\0');

        ptr = temp.data();

        return ptr;

    }





    json jsonData;

    obj->Serialize(jsonData);



    std::string jsonDataStr = jsonData.dump();



    temp.reserve(jsonDataStr.size() + 1);

    memcpy(temp.data(),jsonDataStr.c_str(),jsonDataStr.size() + 1);

    ptr = temp.data();





    return ptr;

}





ClassesArray getInstantiableClasses()

{

    static std::vector<int64_t> ids;

    static std::vector<std::vector<char>> names;

    static std::vector<const char*> names_char;



    ids.clear();

    names.clear();

    names_char.clear();



    for(const auto& [id,name] : GameObject::GetInstantiableClassesIDsToNames()) {

        std::vector<char> temp(name.size() + 1);

        memcpy(temp.data(),name.c_str(),name.size() + 1);

        names.push_back(temp);

        ids.push_back(id);

        names_char.push_back((*(names.end() - 1)).data());

    }





    ClassesArray arr;



    arr.array = ids.data();

    arr.size = ids.size();

    arr.stringArray = names_char.data();

    arr.stringArraySize = names_char.size();

    return arr;

}



void createObjectFromClassID(int64_t classID)

{

    Engine::CreateNewGameObject(classID);

}



bool isEngineInitialized() {

    return Engine::HasInitialized();

}



#ifdef __APPLE__

void passNSViewPointer(void* view) {

    std::cout << "passing pointer!" << std::endl;

    RenderingEngine::PassPlatformSpecificViewPointer(view);

}

#endif



void* getPlatformSpecificPointer() {

    if(!Engine::HasInitialized()){

        return nullptr;

    }

    return RenderingEngine::GetPlatformSpecificPointer();

}







//__END__CPP__IMPL__
""");

      Directory(path.join(projectPath,"generated")).createSync(recursive: true);

      FileViewerPanel.leftInitialDirectory.value = Directory(projectPath);
      FileViewerPanel.currentDirectory.value = Directory(path.join(projectPath,"assets"));

      await reloadProject();

      _isProjectLoaded = true;


      return;

    }
    
    map[projectPath] = {
      "name":projectName
    };


    if(!Directory(projectPath).existsSync()) {
      Directory(projectPath).createSync(recursive: true);
    }

    Directory(path.join(projectPath,"assets")).createSync(recursive: true);

    //await TyphonCPPInterface.extractIncludesFromAssets(path.join(projectPath,"includes"));

    ByteData cmakeTemplateData = await rootBundle.load("assets/cmake_template.txt");
    String cmakeTemplateString = utf8.decode(cmakeTemplateData.buffer.asUint8List(cmakeTemplateData.offsetInBytes,cmakeTemplateData.lengthInBytes));



    cmakeTemplateString = cmakeTemplateString.replaceAll('__CMAKE__VERSION__','3.16')
    .replaceAll('__PROJECT__NAME__',projectFilteredName);


    await File(path.join(projectPath,"CMakeLists.txt")).writeAsString(cmakeTemplateString);





    Directory(path.join(projectPath,"build")).createSync();

    File(path.join((await getApplicationSupportDirectory()).path,"lib",Platform.isMacOS ? "libshader_compiler_dynamic.dylib" : Platform.isWindows? "shader_compiler_dynamic.dll" : "shader_compiler_dynamic.so")).copySync(path.join(projectPath,"build",Platform.isMacOS ? "libshader_compiler_dynamic.dylib" : Platform.isWindows? "shader_compiler_dynamic.dll" : "shader_compiler_dynamic.so"));
    
    await saveProjectsJSON(map);

    return await initializeProject(projectDirectoryPath, projectName);

  }

  Future<List<String>> __findPathsToInclude(Directory directory) async {
    List<String> arr = [];
    for(var maybeFile in await directory.list().toList()){
      if(maybeFile is File && maybeFile.path.substring(maybeFile.path.lastIndexOf(".")) == ".h") {
        arr.add(path.relative(maybeFile.path,from:projectPath));
      }
      if(maybeFile is Directory){
        arr.addAll(await __findPathsToInclude(maybeFile));
      }
    } 
    return arr;

  }

  Future<List<String>> __findSourcesToAdd(Directory directory) async {
    List<String> sources = [];
    for(var maybeFile in await directory.list().toList()){
      if(maybeFile is File && [".cpp",".cc",".c"].contains(maybeFile.path.substring(maybeFile.path.lastIndexOf(".")))) {
        sources.add(path.relative(maybeFile.path,from:projectPath));
      }
      if(maybeFile is Directory){
        sources.addAll(await __findSourcesToAdd(maybeFile));
      }
    } 
    return sources;

  }


  Process? currentProcess;

  Future<void> recompileProject() async {
    
    if(projectPath == "" || projectName == "" || projectFilteredName == ""){
      return;
    }
    print("recompiling...");


    if(Directory(path.join(projectPath,"generated")).existsSync()){
      Directory(path.join(projectPath,"generated")).deleteSync(recursive: true);
    }
    
    
    List<String> includes = await __findPathsToInclude(Directory(path.join(projectPath,"assets")));

    Directory(path.join(projectPath,"generated")).createSync();

    for(String include in includes){
      String pathGenerated = path.join(Engine.instance.projectPath,"generated",path.relative(include,from:"assets"));

      String fileText = File(path.join(projectPath,include)).readAsStringSync();
      fileText = CPPParser.removeComments(fileText);

      var mapWithClassesProperties = CPPParser.getClassesProperties(fileText);


      for(String className in mapWithClassesProperties.keys){
        if(!mapWithClassesProperties[className]["inheritance"].contains("DerivedFromGameObject")) {
          continue;
        }
        String classText = mapWithClassesProperties[className]["class_text"]!;
        int lastIndex = classText.lastIndexOf("}");

        String newClassText = """${classText.substring(0,lastIndex)}
    void InternalSerialize(json& jsonData) {
      ${mapWithClassesProperties[className]["variables"]!.map((e) => 'jsonData["${e}"] = ${e};').toList().join("\n")}
    }
          
    void InternalDeserialize(const json& jsonData) {
      ${mapWithClassesProperties[className]["variables"]!.map((e) => 'jsonData.at("${e}").get_to(${e});').toList().join("\n")}
    }
};""";
        fileText = fileText.replaceAll("$classText;", newClassText);

      }




      File(pathGenerated).createSync();
      File(pathGenerated).writeAsStringSync(fileText);
    }
    
    includes = await __findPathsToInclude(Directory(path.join(projectPath,"generated")));


    //adding source files to cmakelists
    List<String> sourcesPathRelative = await __findSourcesToAdd(Directory(path.join(projectPath,"generated")));

    File cmakeFile = File(path.join(projectPath,"CMakeLists.txt"));

    List<String> cmakeLines = cmakeFile.readAsLinesSync();
    String cmakeFileNewText = "";
    bool shouldAdd = true;
    for(String line in cmakeLines){
      if(line.contains("#__BEGIN__PROJECT__SOURCES__")){
        shouldAdd = false;
      }
      if(line.contains("#__END__PROJECT__SOURCES__")){
        line += "   #__BEGIN__PROJECT__SOURCES__\n";
        for(String path in sourcesPathRelative){
          line += "   $path\n";
        }
        shouldAdd = true;
      }

      if(shouldAdd){
        cmakeFileNewText += line + "\n";
      }

    }
  
    cmakeFile.writeAsStringSync(cmakeFileNewText);

    //finding includes
    File bindingsFile = File(path.join(projectPath,"bindings.cpp"));
    String bindingsGeneratedData = "";
    List<String> lines = bindingsFile.readAsLinesSync();
    for(String line in lines) {
      
      if(line.contains("//__INCLUDE__CREATED__CLASSES__")){
        includes.forEach((element) { 
          if(element == "generated/entry.h" || element == "generated\\entry.h"){
            return;
          }
          bindingsGeneratedData += '#include "${element}"\n';
        });
        continue;
      }
      if(line.contains("//__INITIALIZE__CREATED__CLASSES__")){
        includes.forEach((element) {
          if(element == "generated/entry.h" || element == "generated\\entry.h"){
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

    File bindingsGeneratedCPP = File(path.join(projectPath,"bindings_generated.h"));
    bindingsGeneratedCPP.createSync();
    bindingsGeneratedCPP.writeAsString("""#pragma once
#include "engine.h"
#include "assets/entry.h"

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

  //__BEGIN__CPP__EXPORTS__
    #ifdef __APPLE__

    FFI_PLUGIN_EXPORT void passNSViewPointer(void* view);

    #endif

    FFI_PLUGIN_EXPORT void setPlatformSpecificWindowSizeAndPos(double x,double y,double width,double height);

    FFI_PLUGIN_EXPORT void* getPlatformSpecificPointer();

    FFI_PLUGIN_EXPORT bool initializeCppLibrary();

    FFI_PLUGIN_EXPORT void onMouseMove(double positionX,double positionY);

    FFI_PLUGIN_EXPORT void onKeyboardKeyDown(int64_t input);

    FFI_PLUGIN_EXPORT void onKeyboardKeyUp(int64_t input);

    FFI_PLUGIN_EXPORT void onUpdateCall(double dt);

    FFI_PLUGIN_EXPORT void passProjectPath(const char* path);

    FFI_PLUGIN_EXPORT void attachEnqueueRender(EnqueueObjectRender func);

    FFI_PLUGIN_EXPORT void attachEnqueueOnChildrenChanged(OnChildrenChangedFunc func);

    FFI_PLUGIN_EXPORT void unloadLibrary();

    FFI_PLUGIN_EXPORT void createObjectFromClassID(int64_t classID);

    FFI_PLUGIN_EXPORT ClassesArray getInstantiableClasses();

    FFI_PLUGIN_EXPORT bool isEngineInitialized();

    FFI_PLUGIN_EXPORT AliveObjectsArray getAliveObjects();

    FFI_PLUGIN_EXPORT const char* getObjectNameByID(int64_t id);

    FFI_PLUGIN_EXPORT void removeObjectByID(int64_t id);

    FFI_PLUGIN_EXPORT const char* getObjectSerializationByID(int64_t id);

    

//__END__CPP__EXPORTS__


#ifdef __cplusplus
}
#endif
""");

    var libPath = await TyphonCPPInterface.getLibraryPath();
    var cmakeLocationCommand = await TyphonCPPInterface.getCMakeCommand();
    currentProcess = await Process.start(cmakeLocationCommand, ["./","-B build"],workingDirectory: projectPath,runInShell: true);
    showDialog(
        barrierDismissible: false,
        context: MyApp.globalContext.currentContext!,
        builder:(context) {
        return RecompilingDialog(
          process: currentProcess!,
          onLeaveRequest: () {
            currentProcess!.kill();
          },
        );
      },);

    if(await currentProcess?.exitCode != 0){
      loadProjectLibrary();
      lastCompilationResult.value = false;
      Navigator.of(MyApp.globalContext.currentContext!).pop();
      return;
    }
    Navigator.of(MyApp.globalContext.currentContext!).pop();

    if(Platform.isMacOS){

      currentProcess = await Process.start("make",[projectFilteredName],runInShell: true,workingDirectory: path.join(projectPath,"build"));
      
    showDialog(
        barrierDismissible: false,
        context: MyApp.globalContext.currentContext!, 
        builder:(context) {
        return RecompilingDialog(
          process: currentProcess!,
          onLeaveRequest: () {
            currentProcess!.kill();
          },
        );
      },);
      if(await currentProcess?.exitCode != 0){
        loadProjectLibrary();
        lastCompilationResult.value = false;
        Navigator.of(MyApp.globalContext.currentContext!).pop();
        return;
      }

    } 
    if(Platform.isWindows){
      currentProcess = await Process.start("msbuild",["${projectFilteredName}.sln","/target:${projectFilteredName}","/p:Configuration=Debug"],workingDirectory: path.join(projectPath,"build"),runInShell: true);
      
      showDialog(
        barrierDismissible: false,
        context: MyApp.globalContext.currentContext!, 
        builder:(context) {
        return RecompilingDialog(
          process: currentProcess!,
          onLeaveRequest: () {
            currentProcess!.kill();
          },
        );
      },);
      if(await currentProcess?.exitCode != 0){
        loadProjectLibrary();
        lastCompilationResult.value = false;
        Navigator.of(MyApp.globalContext.currentContext!).pop();
        return;
      }
    }
    Navigator.of(MyApp.globalContext.currentContext!).pop();
    lastCompilationResult.value = true;
    
    loadProjectLibrary();

    
    onRecompileNotifier.value++;
        
    
  }

  Future<TyphonBindings?> loadProjectLibrary() async {
    return await TyphonCPPInterface.initializeLibraryAndGetBindings(path.join(projectPath,"build",
      Platform.isMacOS ? "lib${projectFilteredName}.dylib" : Platform.isWindows? "Debug/${projectFilteredName}.dll" : "" //TODO!
    ));
  }

  Future<void> loadAtlasImage() async {
    File atlasImageFile = File(path.join(projectPath,"build","texture_atlas","atlas0.png"));
    if(!atlasImageFile.existsSync()){
      print("could not load atlas image!");
    }
    else {
      
      Uint8List bytes = await atlasImageFile.readAsBytes();
      atlasImage = (await (await instantiateImageCodec(bytes)).getNextFrame()).image;
      print("loaded atlas image!");
    }

  }

  /* @override
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
  }  */

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

  /* @override
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

  } */

}