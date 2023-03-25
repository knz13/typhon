








import 'dart:ffi';
import 'dart:io';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:typhon/typhon_bindings_generated.dart';


String libPath = 
  Platform.isMacOS? 'libtyphon.dylib'
  : Platform.isWindows ? 'lib/typhon.dll'
  : path.join(Directory.current.path,'lib','typhon.so');


Future<String> _extractLib() async {
    if(Platform.isMacOS){
      return libPath;
    }
    ByteData data = await rootBundle.load("assets/$libPath");
    List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    
    String executablePath = Platform.resolvedExecutable.replaceAll('\\', '/');
    String filePath =  "${executablePath.substring(0,executablePath.lastIndexOf('/'))}/data/$libPath";
    
    Directory libDir = Directory(filePath.substring(0,filePath.lastIndexOf("/")));

    if(!libDir.existsSync()){
      libDir.createSync();
    }

    print(filePath);

    await File(filePath).writeAsBytes(bytes);

    return filePath;
  }

DynamicLibrary? _lib;

TyphonBindings? _bindings;

Future<TyphonBindings> initializeLibraryAndGetBindings() async {
  if(_lib == null){
    String libraryPath = await _extractLib();
    _lib ??= DynamicLibrary.open(libraryPath);
  }

  _bindings = TyphonBindings(_lib!);

  return _bindings!;
}


TyphonBindings getCppFunctions() {
  return _bindings!;
}

