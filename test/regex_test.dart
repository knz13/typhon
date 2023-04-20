import 'dart:io';

import 'package:typhon/regex_parser.dart';
import 'package:test/test.dart';

void main() {
  test('Parsing cpp files', () {
    String fileData = File("c_sharp_interface/src/mono_manager.h").readAsStringSync();

    var map = CPPParser.getClassesText(fileData);
    var mapWithVariables = CPPParser.extractVariableFromClasses(map);

    expect(mapWithVariables.containsKey("MonoManager"),true);
    expect(mapWithVariables["MonoManager"]!.length, 1);
    expect(mapWithVariables["MonoManager"]!.contains("_initialized"), true);
  });
  test('Parsing gameobject', () {
    String fileData = File("c_sharp_interface/src/game_object.h").readAsStringSync();

    var map = CPPParser.getClassesText(fileData);
    var mapWithVariables = CPPParser.extractVariableFromClasses(map);
    expect(mapWithVariables.containsKey("GameObject"),true);
    expect(mapWithVariables["GameObject"]!.length,3);
    expect(mapWithVariables["GameObject"]!.contains("className"),true);
    expect(mapWithVariables["GameObject"]!.contains("onDestroyEvent"),true);
    expect(mapWithVariables["GameObject"]!.contains("handle"),true);
    
  });
}