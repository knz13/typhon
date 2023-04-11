








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

    return path.join(docsDir.absolute.path,"Typhon","lib");

  }



  static Future<String> extractLib() async {

      Directory docsDir = await getApplicationSupportDirectory();


      Directory(path.join(docsDir.path,"Typhon","lib")).createSync(recursive: true);
        
      if(Platform.isMacOS){
        ByteData data = await rootBundle.load("assets/lib/libtyphon.dylib");
        List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

        await File(path.join(docsDir.path,"Typhon","lib","libtyphon.dylib")).writeAsBytes(bytes);
        return libPath;
      }
      ByteData data = await rootBundle.load("assets/$libPath");
      List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      
      String executablePath = Platform.resolvedExecutable.replaceAll('\\', '/');
      String filePath =  path.join(docsDir.path,"Typhon",libPath);

      print(filePath);

      await File(filePath).writeAsBytes(bytes);

      return filePath;
    }


  static Future<void> extractImagesFromAssets() async {
    try {
      // Get the executable directory
      Directory appDocDir = await getApplicationSupportDirectory();
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
        String imageName = path.relative(assetPath,from:"assets/lib/includes");
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


  static DynamicLibrary? _lib;

  static TyphonBindings? _bindings;

  static Future<TyphonBindings> initializeLibraryAndGetBindings(String pathToLibrary) async {
    if(_lib != null){
        _bindings!.unloadLibrary();

        _lib = null;
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

}