import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';
import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart' hide Image;
import 'dart:math';
import 'package:flutter/services.dart'
    show
        ByteData,
        Clipboard,
        ClipboardData,
        RawKeyDownEvent,
        RawKeyUpEvent,
        rootBundle;
import 'package:flutter/src/services/keyboard_key.g.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:typhon/console_panel.dart';
import 'package:typhon/general_widgets/general_widgets.dart';
import 'package:typhon/main.dart';
import 'package:typhon/native_view_interface.dart';
import 'package:typhon/recompiling_dialog.dart';
import 'package:typhon/regex_parser.dart';
import 'package:typhon/typhon_bindings.dart';
import 'package:typhon/typhon_bindings_generated.dart';

import 'features/project_choice_panel/data/project_model.dart';
import 'file_viewer_panel/file_viewer_panel.dart';

void copyDirectorySync(Directory source, Directory destination) {
  /// create destination folder if not exist
  if (!destination.existsSync()) {
    destination.createSync(recursive: true);
  }

  /// get all files from source (recursive: false is important here)
  source.listSync(recursive: false).forEach((entity) {
    final newPath =
        destination.path + Platform.pathSeparator + path.basename(entity.path);
    if (entity is File) {
      entity.copySync(newPath);
    } else if (entity is Directory) {
      copyDirectorySync(entity, Directory(newPath));
    }
  });
}

class EngineRenderingDataFromAtlas {
  int width;
  int height;
  int imageX;
  int imageY;
  double anchorX;
  double anchorY;
  double scale;
  double angle;

  EngineRenderingDataFromAtlas(
      {required this.width,
      required this.height,
      required this.imageX,
      required this.imageY,
      required this.anchorX,
      required this.anchorY,
      required this.scale,
      required this.angle});
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
    if (hasInitializedProject()) {
      _shouldRecompile = true;
      reloadProject();
    }
  }

  bool shouldRecompile() {
    return _shouldRecompile;
  }

  Future<List<ProjectModel>> getProjectsJSON() async {
    Directory privateDir = await getApplicationSupportDirectory();
    File projectsFile = File(path.join(privateDir.path, "projects.json"));
    if (projectsFile.existsSync()) {
      String fileData = projectsFile.readAsStringSync();
      var map = (jsonDecode(fileData)) as Map<String,dynamic>;

      List<ProjectModel> projects = [];

      projects = map.entries
          .map((e) => ProjectModel.fromJson({
                "name": e.value["name"],
                "location": e.key,
              }))
          .toList();

      return projects;
    } else {
      projectsFile.writeAsStringSync("{}");

      return [];
    }
  }

  Future<void> saveProjectsJSON(List<ProjectModel> projects) async {
    Directory privateDir = await getApplicationSupportDirectory();
    File projectsFile = File(path.join(privateDir.path, "projects.json"));

    var mapToSave = Map<String, dynamic>.fromEntries(projects.map((e) => MapEntry(e.location, e.toJson())));

    projectsFile.writeAsStringSync(jsonEncode(mapToSave));
  }

  bool hasInitializedProject() {
    return _isProjectLoaded;
  }

  void detachPlatformSpecificView() {
    if (TyphonCPPInterface.checkIfLibraryLoaded()) {
      NativeViewInterface.detachCPPPointer();
    }
  }

  void attachPlatformSpecificView() {
    if (TyphonCPPInterface.checkIfLibraryLoaded()) {
      var ptr =
          TyphonCPPInterface.getCppFunctions().getPlatformSpecificPointer();
      if (ptr != nullptr) {
        NativeViewInterface.attachCPPPointer(ptr);
      }
    }
  }

  Future<void> reloadProject() async {
    if (_isReloading) {
      return;
    }
    _isReloading = true;
    unload();

    await TyphonCPPInterface.extractImagesFromAssets(
        path.join(projectPath, "build", "images"));

    await recompileProject();
    if (!TyphonCPPInterface.checkIfLibraryLoaded()) {
      print("Could not load library!");
      _isReloading = false;
      return;
    }

    var library = TyphonCPPInterface.getCppFunctions();
    library.passProjectPath(projectPath.toNativeUtf8().cast());
    library.attachEnqueueRender(Pointer.fromFunction(enqueueRender));
    library.attachOnChildrenChanged(Pointer.fromFunction(onCppChildrenChanged));
    library.initializeCppLibrary();
    /* if (Platform.isMacOS) {
      var ptr = library.getPlatformSpecificPointer();
      NativeViewInterface.attachCPPPointer(ptr);
    } */
    library.passPlatformSpecificViewPointer(
        await NativeViewInterface.getPlatformSpecificViewPointer());

    (() async {
      while (true) {
        if (library.isEngineInitialized() == true) {
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
    if (currentProcess != null) {
      currentProcess!.kill();
    }
    currentProcess = null;

    if (TyphonCPPInterface.checkIfLibraryLoaded()) {
      NativeViewInterface.detachCPPPointer().then((value) {
        TyphonCPPInterface.getCppFunctions().unloadLibrary();
        TyphonCPPInterface.detachLibrary();
      });
    }
  }

  static void onCppChildrenChanged() {
    AliveObjectsArray arr =
        TyphonCPPInterface.getCppFunctions().getAliveParentlessObjects();

    List<int> list = arr.array.asTypedList(arr.size).toList();
    print("found these objects that are parentless: ${list}");

    Engine.instance.currentChildren.value = list;
  }

  Future<void> initializeProject(
      String projectDirectoryPath, String projectName) async {
    //testing if project exists and loading it if true
    var projectsList = await getProjectsJSON();
    var projectFilteredName =
        projectName.replaceAllMapped(RegExp(r'[^a-zA-Z0-9]'), (match) => '_');
    var projectPath = path.join(projectDirectoryPath, projectFilteredName);

    if (projectsList.where((element) => element.location == projectPath).isNotEmpty) {
      this.projectPath = projectPath;
      this.projectName = projectName;
      this.projectFilteredName = projectFilteredName;

      String cmakeFileData = "";
      File cmakeFile = File(path.join(projectPath, "CMakeLists.txt"));
      List<String> lines = cmakeFile.readAsLinesSync();
      for (String line in lines) {
        if (line.contains("__TYPHON__LIBRARY__LOCATION__")) {
          var projPath = (await TyphonCPPInterface.getLibraryPath())
              .replaceAll("\\", "/")
              .replaceAll(" ", "\\ ");
          cmakeFileData +=
              "set(TYPHON_LIBRARY_LOCATION $projPath) #__TYPHON__LIBRARY__LOCATION__";
          cmakeFileData += "\n";
          continue;
        }

        cmakeFileData += line;
        cmakeFileData += "\n";
      }

      await cmakeFile.writeAsString(cmakeFileData);

      File entryFile = File(path.join(projectPath, "assets", "entry.h"));

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

      File bindingsFile = File(path.join(projectPath, "bindings.cpp"));

      await bindingsFile.writeAsString("""
#include "bindings_generated.h"
//__BEGIN__CPP__IMPL__
#include <iostream>

#include <stdint.h>

#include "engine.h"

#include "rendering_engine.h"

#include "prefab/prefab.h"

#include "auxiliary_libraries/model_loader.h"

#include "component/make_component.h"

//__INCLUDE__CREATED__CLASSES__


//including internal classes
#include "component/default_components/transform.h"
#include "auxiliary_libraries/model_loader.h"
#include "auxiliary_libraries/shader_compiler.h"
#include "prefab/defaults/cube.h"
#include "prefab/defaults/empty_object.h"


bool initializeCppLibrary()

{



    //__INITIALIZE__CREATED__COMPONENTS__



    //__INITIALIZE__CREATED__CLASSES__




    //initializing prefabs!
    Transform();
    ModelLoader();
    ShaderCompiler();
    Cube();
    EmptyObject();


    Engine::Initialize();



    return true;

}



void onMouseMove(double positionX, double positionY)

{

    EngineInternals::SetMousePosition(Vector2f(positionX, positionY));

}



void onKeyboardKeyDown(int64_t input)

{

    EngineInternals::PushKeyDown(input);

}



void onKeyboardKeyUp(int64_t input)

{

    EngineInternals::PushKeyUp(input);

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

    EngineInternals::enqueueRenderFunc = [=](double x, double y, int64_t width, int64_t height, int64_t imageX, int64_t imageY, double anchorX, double anchorY, double scale, double angle)

    {

        func(x, y, width, height, imageX, imageY, anchorX, anchorY, scale, angle);

    };

}



void attachOnChildrenChanged(OnChildrenChangedFunc func)

{

    EngineInternals::onChildrenChangedFunc = [=]()

    {

        func();

    };

}



void unloadLibrary()

{

    Engine::Unload();

}



void onRenderCall()

{

    RenderingEngine::Render();

}



AliveObjectsArray getAliveParentlessObjects()

{

    static std::vector<int64_t> ids;



    ids.clear();

    ids.reserve(Engine::NumberAlive());

    Engine::View<ObjectInternals::ParentlessTag>([&](Typhon::Object obj)

                                                 { ids.push_back(static_cast<int64_t>(obj.ID())); });



    AliveObjectsArray arr;

    arr.array = ids.data();

    arr.size = ids.size();



    return arr;

}



const char *getObjectNameByID(int64_t id)

{

    static std::vector<char> temp = std::vector<char>();

    static const char *ptr = nullptr;



    temp.clear();



    Typhon::Object obj = Engine::GetObjectFromID(id);



    if (!obj.Valid())

    {

        temp.push_back(' ');

        ptr = temp.data();

        return ptr;

    }

    temp.reserve(obj.Name().size() + 1);

    memcpy(temp.data(), obj.Name().c_str(), obj.Name().size() + 1);

    ptr = temp.data();



    return ptr;

};



void removeObjectByID(int64_t id)

{

    if (Engine::ValidateHandle(id))

    {

        Engine::RemoveObject(id);

    }

}



bool setObjectName(int64_t objectID, const char *str, int64_t size)

{

    if (Engine::ValidateHandle(objectID))

    {

        Engine::GetObjectFromID(objectID).SetName(std::string(str, size));

        EngineInternals::onChildrenChangedFunc();

        return true;

    }

    return false;

}



const char *getObjectSerializationByID(int64_t id)

{



    static std::vector<char> temp = std::vector<char>();

    static const char *ptr = nullptr;



    temp.clear();



    Typhon::Object obj = Engine::GetObjectFromID(id);



    if (!obj.Valid())

    {

        std::cout << "object not valid!" << std::endl;

        temp.resize(3);

        temp.push_back('{');

        temp.push_back('}');

        ptr = temp.data();

        return ptr;

    }



    json jsonData;

    obj.Serialize(jsonData);



    std::string jsonDataStr = jsonData.dump();



    temp.resize(jsonDataStr.size() + 1);

    memcpy(temp.data(), jsonDataStr.c_str(), jsonDataStr.size() + 1);

    ptr = temp.data();



    return ptr;

}



const char *getObjectInspectorUIByID(int64_t id)

{

    static std::vector<char> temp = std::vector<char>();

    static const char *ptr = nullptr;



    temp.clear();



    Typhon::Object obj = Engine::GetObjectFromID(id);



    if (!obj.Valid())

    {

        std::cout << "object not valid!" << std::endl;

        temp.push_back('{');

        temp.push_back('}');

        ptr = temp.data();

        return ptr;

    }



    json jsonData = json::object();

    jsonData["name"] = obj.Name();

    jsonData["components"] = json::array();

    obj.ForEachComponent([&](Component &comp)

                         { jsonData["components"].push_back(comp.InternalBuildEditorUI().GetJSON()); });



    std::string jsonDataStr = jsonData.dump();



    temp.resize(jsonDataStr.size() + 1);

    memcpy(temp.data(), jsonDataStr.c_str(), jsonDataStr.size() + 1);

    ptr = temp.data();



    return ptr;

}



const char *getObjectChildTree(int64_t id)

{

    static std::vector<char> temp = std::vector<char>();

    static const char *ptr = nullptr;



    temp.clear();



    Typhon::Object obj = Engine::GetObjectFromID(id);



    if (!obj.Valid())

    {

        std::cout << "object not valid!" << std::endl;

        temp.resize(3);

        temp.push_back('{');

        temp.push_back('}');

        ptr = temp.data();

        return ptr;

    }



    json jsonData = json::object();

    obj.ExecuteForEveryChildInTree([&](Typhon::Object &tempObj)

                                   {

        if(tempObj.NumberOfChildren() > 0){

            jsonData[std::to_string(static_cast<int64_t>(tempObj.ID()))] = json::array();

            for(auto entity : tempObj.Children()){

                jsonData[std::to_string(static_cast<int64_t>(tempObj.ID()))].push_back(static_cast<int64_t>(entity));

            }

        } },

                                   true);



    std::string jsonDataStr = jsonData.dump();



    temp.resize(jsonDataStr.size() + 1);

    memcpy(temp.data(), jsonDataStr.c_str(), jsonDataStr.size() + 1);

    ptr = temp.data();



    return ptr;

}



char *getInstantiableClasses()

{

    static std::vector<char> classesJSON;

    static char *classesJSONChar = nullptr;



    classesJSON.clear();



    std::string jsonData = PrefabInternals::GetPrefabsJSON();



    classesJSON.resize(jsonData.size() + 1);



    memcpy(classesJSON.data(), jsonData.c_str(), jsonData.size() + 1);

    classesJSONChar = classesJSON.data();



    return classesJSONChar;

}



char *getInstantiableComponents()

{

    static std::vector<char> classesJSON;

    static char *classesJSONChar = nullptr;



    classesJSON.clear();



    std::string jsonData = ComponentInternals::GetDefaultComponentsJSON();



    classesJSON.resize(jsonData.size() + 1);



    memcpy(classesJSON.data(), jsonData.c_str(), jsonData.size() + 1);

    classesJSONChar = classesJSON.data();



    return classesJSONChar;

}



void createObjectFromClassID(int64_t classID)

{

    PrefabInternals::CreatePrefabFromID(classID);

}



bool isEngineInitialized()

{

    return Engine::HasInitialized();

}



void passPlatformSpecificViewPointer(void *view)

{



    RenderingEngine::PassPlatformSpecificViewPointer(view);

}



void *getPlatformSpecificPointer()

{

    if (!Engine::HasInitialized())

    {

        return nullptr;

    }

    return RenderingEngine::GetPlatformSpecificPointer();

}



bool setObjectParent(int64_t objectID, int64_t parentID)

{

    if (!Engine::ValidateHandle(objectID) || !Engine::ValidateHandle(parentID))

    {

        return false;

    }



    Typhon::Object(Engine::IDFromHandle(objectID)).SetParent(Typhon::Object(Engine::IDFromHandle(parentID)));

    return true;

}

bool removeObjectFromParent(int64_t objectID)

{

    if (!Engine::ValidateHandle(objectID))

    {

        return false;

    }

    Typhon::Object(Engine::IDFromHandle(objectID)).RemoveFromParent();

    return true;

}



char *getContextMenuForFilePath(const char *filePath, int64_t size)

{

    static std::vector<char> responseJSON;

    static char *responsePtr = nullptr;



    responseJSON.clear();



    responseJSON.push_back('[');

    responseJSON.push_back(']');



    responsePtr = responseJSON.data();



    return responsePtr;

}



void loadModelFromPath(const char *filePath, int64_t size)

{

    std::string path = std::string(filePath, size);



    std::cout << ModelLoader::LoadModelFromFile(path).meshes.size() << std::endl;

}



void addComponentToObject(int64_t objectID, int64_t componentClassID)

{

    if (Engine::ValidateHandle(objectID))

    {

        Typhon::Object obj = Engine::GetObjectFromID(objectID);

        auto componentMeta = entt::resolve(entt::hashed_string(std::to_string(componentClassID).c_str()));

        if (componentMeta)

        {

            auto func = componentMeta.func(entt::hashed_string(std::string("AddComponent").c_str()));

            if (func)

            {

                func.invoke({}, obj.ID());

                EngineInternals::onChildrenChangedFunc();

            }

        }

        else

        {

            std::cout << "Could not find component with id => " << componentClassID << std::endl;

        }

    }

}



//__END__CPP__IMPL__
""");

      Directory(path.join(projectPath, "generated"))
          .createSync(recursive: true);

      FileViewerPanel.leftInitialDirectory.value = Directory(projectPath);
      FileViewerPanel.currentDirectory.value =
          Directory(path.join(projectPath, "assets"));

      await reloadProject();

      _isProjectLoaded = true;

      return;
    }

    projectsList.add(ProjectModel(name: projectName, location: projectPath,lastModified: DateTime.now()));

    if (!Directory(projectPath).existsSync()) {
      Directory(projectPath).createSync(recursive: true);
    }

    Directory(path.join(projectPath, "assets")).createSync(recursive: true);

    //await TyphonCPPInterface.extractIncludesFromAssets(path.join(projectPath,"includes"));

    ByteData cmakeTemplateData =
        await rootBundle.load("assets/cmake_template.txt");
    String cmakeTemplateString = utf8.decode(cmakeTemplateData.buffer
        .asUint8List(
            cmakeTemplateData.offsetInBytes, cmakeTemplateData.lengthInBytes));

    cmakeTemplateString = cmakeTemplateString
        .replaceAll('__CMAKE__VERSION__', '3.16')
        .replaceAll('__PROJECT__NAME__', projectFilteredName);

    await File(path.join(projectPath, "CMakeLists.txt"))
        .writeAsString(cmakeTemplateString);

    Directory(path.join(projectPath, "build")).createSync();

    copyDirectorySync(
        Directory(path.join((await getApplicationSupportDirectory()).path,
            "lib", "auxiliary_libraries")),
        Directory(path.join(projectPath, "build")));

    

    await saveProjectsJSON(projectsList);

    return await initializeProject(projectDirectoryPath, projectName);
  }

  Future<List<String>> __findPathsToInclude(Directory directory) async {
    List<String> arr = [];
    for (var maybeFile in await directory.list().toList()) {
      if (maybeFile is File &&
          maybeFile.path.substring(maybeFile.path.lastIndexOf(".")) == ".h") {
        arr.add(path.relative(maybeFile.path, from: projectPath));
      }
      if (maybeFile is Directory) {
        arr.addAll(await __findPathsToInclude(maybeFile));
      }
    }
    return arr;
  }

  Future<List<String>> __findSourcesToAdd(Directory directory) async {
    List<String> sources = [];
    for (var maybeFile in await directory.list().toList()) {
      if (maybeFile is File &&
          [".cpp", ".cc", ".c"].contains(
              maybeFile.path.substring(maybeFile.path.lastIndexOf(".")))) {
        sources.add(path.relative(maybeFile.path, from: projectPath));
      }
      if (maybeFile is Directory) {
        sources.addAll(await __findSourcesToAdd(maybeFile));
      }
    }
    return sources;
  }

  Process? currentProcess;

  Future<void> recompileProject() async {
    if (projectPath == "" || projectName == "" || projectFilteredName == "") {
      return;
    }
    print("recompiling...");

    if (Directory(path.join(projectPath, "generated")).existsSync()) {
      Directory(path.join(projectPath, "generated"))
          .deleteSync(recursive: true);
    }

    List<String> includes =
        await __findPathsToInclude(Directory(path.join(projectPath, "assets")));

    Directory(path.join(projectPath, "generated")).createSync();

    for (String include in includes) {
      String pathGenerated = path.join(Engine.instance.projectPath, "generated",
          path.relative(include, from: "assets"));

      String fileText =
          File(path.join(projectPath, include)).readAsStringSync();
      fileText = CPPParser.removeComments(fileText);

      var mapWithClassesProperties = CPPParser.getClassesProperties(fileText);

      for (String className in mapWithClassesProperties.keys) {
        if (!mapWithClassesProperties[className]["inheritance"]
            .contains("DerivedFromGameObject")) {
          continue;
        }
        String classText = mapWithClassesProperties[className]["class_text"]!;
        int lastIndex = classText.lastIndexOf("}");

        String newClassText = """${classText.substring(0, lastIndex)}
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

    includes = await __findPathsToInclude(
        Directory(path.join(projectPath, "generated")));

    //adding source files to cmakelists
    List<String> sourcesPathRelative = await __findSourcesToAdd(
        Directory(path.join(projectPath, "generated")));

    File cmakeFile = File(path.join(projectPath, "CMakeLists.txt"));

    List<String> cmakeLines = cmakeFile.readAsLinesSync();
    String cmakeFileNewText = "";
    bool shouldAdd = true;
    for (String line in cmakeLines) {
      if (line.contains("#__BEGIN__PROJECT__SOURCES__")) {
        shouldAdd = false;
      }
      if (line.contains("#__END__PROJECT__SOURCES__")) {
        line += "   #__BEGIN__PROJECT__SOURCES__\n";
        for (String path in sourcesPathRelative) {
          line += "   $path\n";
        }
        shouldAdd = true;
      }

      if (shouldAdd) {
        cmakeFileNewText += line + "\n";
      }
    }

    cmakeFile.writeAsStringSync(cmakeFileNewText);

    //finding includes
    File bindingsFile = File(path.join(projectPath, "bindings.cpp"));
    String bindingsGeneratedData = "";
    List<String> lines = bindingsFile.readAsLinesSync();
    for (String line in lines) {
      if (line.contains("//__INCLUDE__CREATED__CLASSES__")) {
        includes.forEach((element) {
          if (element == "generated/entry.h" ||
              element == "generated\\entry.h") {
            return;
          }
          bindingsGeneratedData += '#include "${element}"\n';
        });
        continue;
      }
      if (line.contains("//__INITIALIZE__CREATED__CLASSES__")) {
        includes.forEach((element) {
          if (element == "generated/entry.h" ||
              element == "generated\\entry.h") {
            return;
          }
          bindingsGeneratedData +=
              "    ${path.basenameWithoutExtension(element)}();\n";
        });
        continue;
      }
      bindingsGeneratedData += line;

      bindingsGeneratedData += "\n";
    }

    File bindingsGenerated =
        File(path.join(projectPath, "bindings_generated.cpp"));
    bindingsGenerated.createSync();
    bindingsGenerated.writeAsStringSync(bindingsGeneratedData);

    File bindingsGeneratedCPP =
        File(path.join(projectPath, "bindings_generated.h"));
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


    FFI_PLUGIN_EXPORT void passPlatformSpecificViewPointer(void *view);



    FFI_PLUGIN_EXPORT void setPlatformSpecificWindowSizeAndPos(double x, double y, double width, double height);

    FFI_PLUGIN_EXPORT void *getPlatformSpecificPointer();

    FFI_PLUGIN_EXPORT bool initializeCppLibrary();

    FFI_PLUGIN_EXPORT void onMouseMove(double positionX, double positionY);

    FFI_PLUGIN_EXPORT void onKeyboardKeyDown(int64_t input);

    FFI_PLUGIN_EXPORT void onKeyboardKeyUp(int64_t input);

    FFI_PLUGIN_EXPORT void onUpdateCall(double dt);

    FFI_PLUGIN_EXPORT void onRenderCall(double dt);

    FFI_PLUGIN_EXPORT void passProjectPath(const char *path);

    FFI_PLUGIN_EXPORT void attachEnqueueRender(EnqueueObjectRender func);

    FFI_PLUGIN_EXPORT void attachOnChildrenChanged(OnChildrenChangedFunc func);

    FFI_PLUGIN_EXPORT void unloadLibrary();

    FFI_PLUGIN_EXPORT void createObjectFromClassID(int64_t classID);

    FFI_PLUGIN_EXPORT char *getInstantiableClasses();

    FFI_PLUGIN_EXPORT char *getInstantiableComponents();

    FFI_PLUGIN_EXPORT bool isEngineInitialized();

    FFI_PLUGIN_EXPORT AliveObjectsArray getAliveParentlessObjects();

    FFI_PLUGIN_EXPORT const char *getObjectNameByID(int64_t id);

    FFI_PLUGIN_EXPORT void removeObjectByID(int64_t id);

    FFI_PLUGIN_EXPORT const char *getObjectSerializationByID(int64_t id);

    FFI_PLUGIN_EXPORT const char *getObjectInspectorUIByID(int64_t id);

    FFI_PLUGIN_EXPORT const char *getObjectChildTree(int64_t id);

    FFI_PLUGIN_EXPORT bool setObjectParent(int64_t objectID, int64_t parentID);

    FFI_PLUGIN_EXPORT bool setObjectName(int64_t objectID, const char *str, int64_t size);

    FFI_PLUGIN_EXPORT bool removeObjectFromParent(int64_t objectID);

    FFI_PLUGIN_EXPORT char *getContextMenuForFilePath(const char *filePath, int64_t size);

    FFI_PLUGIN_EXPORT void loadModelFromPath(const char *filePath, int64_t size);

    FFI_PLUGIN_EXPORT void addComponentToObject(int64_t objectID,int64_t componentClassID);



//__END__CPP__EXPORTS__


#ifdef __cplusplus
}
#endif
""");

    var libPath = await TyphonCPPInterface.getLibraryPath();
    var cmakeLocationCommand = await TyphonCPPInterface.getCMakeCommand();
    currentProcess = await Process.start(
        cmakeLocationCommand, ["./", "-B build"],
        workingDirectory: projectPath, runInShell: true);
    showDialog(
      barrierDismissible: false,
      context: MainEngineApp.globalContext.currentContext!,
      builder: (context) {
        return RecompilingDialog(
          process: currentProcess!,
          onLeaveRequest: () {
            currentProcess!.kill();
          },
        );
      },
    );

    if (await currentProcess?.exitCode != 0) {
      lastCompilationResult.value = false;
      Navigator.of(MainEngineApp.globalContext.currentContext!).pop();
      return;
    }
    Navigator.of(MainEngineApp.globalContext.currentContext!).pop();

    if (Platform.isMacOS) {
      currentProcess = await Process.start("make", [projectFilteredName],
          runInShell: true, workingDirectory: path.join(projectPath, "build"));

      showDialog(
        barrierDismissible: false,
        context: MainEngineApp.globalContext.currentContext!,
        builder: (context) {
          return RecompilingDialog(
            process: currentProcess!,
            onLeaveRequest: () {
              currentProcess!.kill();
            },
          );
        },
      );

      if (await currentProcess?.exitCode != 0) {
        lastCompilationResult.value = false;
        Navigator.of(MainEngineApp.globalContext.currentContext!).pop();
        return;
      }
    }
    if (Platform.isWindows) {
      currentProcess = await Process.start(
          "msbuild",
          [
            "${projectFilteredName}.sln",
            "/target:${projectFilteredName}",
            "/p:Configuration=Debug"
          ],
          workingDirectory: path.join(projectPath, "build"),
          runInShell: true);

      showDialog(
        barrierDismissible: false,
        context: MainEngineApp.globalContext.currentContext!,
        builder: (context) {
          return RecompilingDialog(
            process: currentProcess!,
            onLeaveRequest: () {
              currentProcess!.kill();
            },
          );
        },
      );
      if (await currentProcess?.exitCode != 0) {
        lastCompilationResult.value = false;
        Navigator.of(MainEngineApp.globalContext.currentContext!).pop();
        return;
      }
    }
    Navigator.of(MainEngineApp.globalContext.currentContext!).pop();
    lastCompilationResult.value = true;

    loadProjectLibrary();

    onRecompileNotifier.value++;
  }

  Future<TyphonBindings?> loadProjectLibrary() async {
    return await TyphonCPPInterface.initializeLibraryAndGetBindings(path.join(
        projectPath,
        "build",
        Platform.isMacOS
            ? "lib${projectFilteredName}.dylib"
            : Platform.isWindows
                ? "Debug/${projectFilteredName}.dll"
                : "" //TODO!
        ));
  }

  Future<void> loadAtlasImage() async {
    File atlasImageFile =
        File(path.join(projectPath, "build", "texture_atlas", "atlas0.png"));
    if (!atlasImageFile.existsSync()) {
      print("could not load atlas image!");
    } else {
      Uint8List bytes = await atlasImageFile.readAsBytes();
      atlasImage =
          (await (await instantiateImageCodec(bytes)).getNextFrame()).image;
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
    while (true) {
      if (isInitialized) {
        return;
      }
      await Future.delayed(Duration(milliseconds: 100));
    }
  }

  static void enqueueRender(
      double x,
      double y,
      int width,
      int height,
      int imageX,
      int imageY,
      double anchorX,
      double anchorY,
      double scale,
      double angle) {
    renderingObjects.add(EngineRenderingDataFromAtlas(
        width: width,
        height: height,
        imageX: imageX,
        imageY: imageY,
        anchorX: anchorX,
        anchorY: anchorX,
        scale: scale,
        angle: angle));
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
