








import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:typhon/typhon_bindings_generated.dart';


class TyphonCPPInterface {


  static String libPath = 
    Platform.isMacOS? 'libtyphon.dylib'
    : Platform.isWindows ? 'lib/typhon.dll'
    : path.join(Directory.current.path,'lib','typhon.so');

  static Future<String> getLibraryPath() async {
    Directory docsDir = await getApplicationSupportDirectory();

    return path.join(docsDir.absolute.path,"lib");

  }
  static DynamicLibrary stdlib = Platform.isWindows ? DynamicLibrary.open('kernel32.dll') : DynamicLibrary.process();


  static int Function(Pointer<Void>) get _dlCloseFunc {
    final funcName = Platform.isWindows ? 'FreeLibrary' : 'dlclose';
    return stdlib.lookup<NativeFunction<Int32 Function(Pointer<Void>)>>(funcName).asFunction();
  }


  static Future<String> extractLib() async {

      Directory docsDir = await getApplicationSupportDirectory();

      Directory libsDir = Directory(path.join(docsDir.path,"lib"));
      libsDir.createSync(recursive: true);
      

      // Get the list of asset files
      String assetManifestJson = await rootBundle.loadString('AssetManifest.json');
      Map<String, dynamic> assetManifestMap = json.decode(assetManifestJson);
      List<String> assetManifest = assetManifestMap.keys.toList();

      List<String> libAssets = assetManifest
          .where((p) {
            return path.isWithin("assets/lib", p);
          })
          .toList();
      int index = 0;
      // Extract images
      for (String assetPath in libAssets) {

        String srcName = path.relative(assetPath,from:"assets/lib");
        File srcFile = File(path.join(libsDir.path, srcName));

        if(assetPath.contains("vendor/") && srcFile.existsSync()){
          continue;
        }
        srcFile.createSync(recursive: true);
        try {

          ByteData data = await rootBundle.load(assetPath);
          List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
          await srcFile.writeAsBytes(bytes, flush: true);
        }
        catch(e) {
          print("Error found while loading file ${srcName}: ${e}");
        }
        index += 1;
        if(index %100 == 0) {
          print("Loaded lib progress: ${index + 1}/${libAssets.length}");
        }
      }
      print("Done loading lib!");

      return libsDir.path;
  }

  

  static Future<void> extractImagesFromAssets(String destination) async {
    try {
      // Get the executable directory

      // Create the 'images' directory if it doesn't exist

      // Get the list of asset files
      if(!Directory(destination).existsSync()){
        Directory(destination).createSync(recursive: true);
      }

      String assetManifestJson = await rootBundle.loadString('AssetManifest.json');
      Map<String, dynamic> assetManifestMap = json.decode(assetManifestJson);
      List<String> assetManifest = assetManifestMap.keys.toList();

      List<String> imageAssets = assetManifest
          .where((p) => path.isWithin("assets/images/", p) && (path.extension(p).toLowerCase() == '.png' || path.extension(p).toLowerCase() == '.jpg'))
          .toList();
      print(imageAssets);
      // Extract images
      for (String assetPath in imageAssets) {

        String imageName = path.basename(assetPath);
        File imageFile = File(path.join(destination, imageName));

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

  static Future<void> extractIncludesFromAssets(String destination) async {
    try {

      // Get the list of asset files
      String assetManifestJson = await rootBundle.loadString('AssetManifest.json');
      Map<String, dynamic> assetManifestMap = json.decode(assetManifestJson);
      List<String> assetManifest = assetManifestMap.keys.toList();

      List<String> imageAssets = assetManifest
          .where((p) => path.extension(p).toLowerCase() == '.h' || path.extension(p).toLowerCase() == ".hpp" || path.extension(p).toLowerCase() == ".inl")
          .toList();

      Directory(destination).create(recursive: true);

      for (String assetPath in imageAssets) {
        String imageName = path.relative(assetPath,from:"assets/lib/src");
        File includeFile = File(path.join(destination, imageName));

        if(includeFile.existsSync()){
          print("Skipping ${includeFile.path}, already copied!");
          continue;
        }

        await includeFile.create(recursive: true);

        ByteData data = await rootBundle.load(assetPath);
        List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

        await includeFile.writeAsBytes(bytes, flush: true);
        //print("Created ${includeFile.path}!");
      }
    } catch (e) {
      print("Error extracting include from assets: $e");
    }
  }

  static DynamicLibrary? getLibraryHandle() {
    return _lib;
  }

  static DynamicLibrary? _lib;

  static TyphonBindings? _bindings;

  static Future<TyphonBindings> initializeLibraryAndGetBindings(String pathToLibrary) async {
    if(_lib != null){
        detachLibrary();
    }
    _lib ??= DynamicLibrary.open(pathToLibrary);
    
    _bindings = TyphonBindings(_lib!);

    return _bindings!;
  }


  static TyphonBindings getCppFunctions() {
    return _bindings!;
  }

  static bool checkIfLibraryLoaded() {
    return _bindings != null;
  }

  static void detachLibrary() {
    print("detaching library!");
    _dlCloseFunc(_lib!.handle);
    _lib = null;
    _bindings = null;
  }

}