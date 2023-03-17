





import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:async';
import 'dart:math';
import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'package:path/path.dart' as path;
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:path_provider/path_provider.dart';


class LuaComponent extends Component {

}

int createComponent(int parent) {
  int id = Engine.generateRandomID();


  while(Engine.registeredLuaComponents.containsKey(id) && id == -1){
    id = Engine.generateRandomID();
  }

  

  LuaComponent component = LuaComponent();
  Engine.registeredLuaComponents[id] = component;


  if(parent != -1 && Engine.registeredLuaComponents.containsKey(parent)){
    Engine.registeredLuaComponents[id]!.add(component);
  }
  else {
    Engine.addLuaComponent(component);
  }


  return id;
}




int removeFromParent(int parent, int child) {

  if(parent == -1 || child == -1){
    return 0;
  }


  return 1;

}


class Engine extends FlameGame {

  static Map<int,Component> registeredLuaComponents = {};
  static Random rng = Random();
  static Engine? instance;
  static String libPath = 
  Platform.isMacOS? path.join('lib', 'libtyphon_lua.dylib')
  : Platform.isWindows ? path.join('lib', 'typhon_lua.dll') 
  : path.join(Directory.current.path,'lib','typhon_lua.so');


  static DynamicLibrary? library;

  static int generateRandomID() {
    return Engine.rng.nextInt(1 << 32);
  }


  static void addLuaComponent(LuaComponent component) {
    Engine.instance?.add(component);
  }

  Future<String> extractLib() async {
    ByteData data = await rootBundle.load("assets/" + libPath);
    List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

    Directory appDocDir = await getApplicationDocumentsDirectory();
    Directory(path.join(appDocDir.path,"lib")).createSync(recursive: true);

    String filePath = path.join(appDocDir.path, libPath);

    await File(filePath).writeAsBytes(bytes);

    return filePath;
  }

  @override
  FutureOr<void> onLoad() {

    extractLib().then((value) {

      print("initializing library!");
      library ??= DynamicLibrary.open(value);
      
      Engine.instance ??= this;
      
      
      Pointer<NativeFunction<Int Function(Int)>> pointer = Pointer.fromFunction(createComponent,0);

      print('here');
      //Engine.library!.lookupFunction("registerCreateComponentFunction")(pointer);
      print('after here');
      
    },);

    

    
    return super.onLoad();
  }

}