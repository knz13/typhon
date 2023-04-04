








import 'dart:convert';
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


Future<void> extractImagesFromAssets() async {
  try {
    // Get the executable directory
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String imagesDirPath = path.join(appDocDir.path,"Typhon","lib",'images');

    // Create the 'images' directory if it doesn't exist
    Directory imagesDir = Directory(imagesDirPath);
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }

    // Get the list of asset files
     String assetManifestJson = await rootBundle.loadString('AssetManifest.json');
    Map<String, dynamic> assetManifestMap = json.decode(assetManifestJson);
    List<String> assetManifest = assetManifestMap.keys.toList();

    List<String> imageAssets = assetManifest
        .where((p) => path.extension(p).toLowerCase() == '.png' || path.extension(p).toLowerCase() == '.jpg')
        .toList();

    // Extract images
    for (String assetPath in imageAssets) {

      String imageName = path.basename(assetPath);
      File imageFile = File(path.join(imagesDir.path, imageName));

      if(imageFile.existsSync()){
        print("Skipping ${imageFile.path}, already copied!");
        continue;
      }

      ByteData data = await rootBundle.load(assetPath);
      List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      await imageFile.writeAsBytes(bytes, flush: true);
      print("Created ${imageFile.path}!");
    }
  } catch (e) {
    print("Error extracting images from assets: $e");
  }
}

Future<void> extractIncludesFromAssets(String destination) async {
  try {
    // Get the executable directory
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String imagesDirPath = path.join(appDocDir.path,"Typhon","lib",'images');

    // Create the 'images' directory if it doesn't exist
    Directory imagesDir = Directory(imagesDirPath);
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }

    // Get the list of asset files
     String assetManifestJson = await rootBundle.loadString('AssetManifest.json');
    Map<String, dynamic> assetManifestMap = json.decode(assetManifestJson);
    List<String> assetManifest = assetManifestMap.keys.toList();

    List<String> imageAssets = assetManifest
        .where((p) => path.extension(p).toLowerCase() == '.png' || path.extension(p).toLowerCase() == '.jpg')
        .toList();

    // Extract images
    for (String assetPath in imageAssets) {

      String imageName = path.basename(assetPath);
      File imageFile = File(path.join(imagesDir.path, imageName));

      if(imageFile.existsSync()){
        print("Skipping ${imageFile.path}, already copied!");
        continue;
      }

      ByteData data = await rootBundle.load(assetPath);
      List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      await imageFile.writeAsBytes(bytes, flush: true);
      print("Created ${imageFile.path}!");
    }
  } catch (e) {
    print("Error extracting images from assets: $e");
  }
}


DynamicLibrary? _lib;

TyphonBindings? _bindings;

Future<TyphonBindings> initializeLibraryAndGetBindings() async {
  if(_lib != null){
      _bindings!.unloadLibrary();
  }
  String libraryPath = await _extractLib();
  _lib ??= DynamicLibrary.open(libraryPath);

  _bindings = TyphonBindings(_lib!);

  return _bindings!;
}


TyphonBindings getCppFunctions() {
  return _bindings!;
}

bool checkIfLibraryLoaded() {
  return _bindings != null;
}

