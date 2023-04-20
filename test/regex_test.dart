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
  test('Parsing complex file', () {
    String fileData = File("c_sharp_interface/src/game_object.h").readAsStringSync();

    var map = CPPParser.getClassesText(fileData);
    var mapWithVariables = CPPParser.extractVariableFromClasses(map);
    expect(mapWithVariables.containsKey("GameObject"),true);
    expect(mapWithVariables["GameObject"]!.length,3);
    expect(mapWithVariables["GameObject"]!.contains("className"),true);
    expect(mapWithVariables["GameObject"]!.contains("onDestroyEvent"),true);
    expect(mapWithVariables["GameObject"]!.contains("handle"),true);
    
  });

  test('Parsing simple user file', () {
    String fileData = """
#include <iostream>


class Something {
public:
  int somethingNamedAfterMe;

  std::string someVariable;

  void myFunc() {};

  int someOtherFunc() {

    int hi;

    return 2;

  };

};
""";

    var map = CPPParser.getClassesText(fileData);
    var mapWithVariables = CPPParser.extractVariableFromClasses(map);
    expect(mapWithVariables.containsKey("Something"),true);
    expect(mapWithVariables["Something"]!.length,2);
    expect(mapWithVariables["Something"]!.contains("somethingNamedAfterMe"),true);
    expect(mapWithVariables["Something"]!.contains("someVariable"),true);
    expect(mapWithVariables["Something"]!.contains("myFunc"),false);
    expect(mapWithVariables["Something"]!.contains("someOtherFunc"),false);

  });

  test('Parsing complex user file', () {
    String fileData = """
#include <iostream>
#include "../engine.h>


template<typename A>
class Something : public DerivedFromGameObject<Something<A>,Traits::SomeTrait,Traits::SomeOtherTrait<Something<A>>> {
public:
  int somethingNamedAfterMe;

  std::string someVariable;

  InsideScope::Variable::A** complexWeirdVar;

  void myFunc() {};

  int someOtherFunc() {

    int hi;

    return 2;

  };

};
""";

    var map = CPPParser.getClassesText(fileData);
    var mapWithVariables = CPPParser.extractVariableFromClasses(map);
    expect(mapWithVariables.containsKey("Something"),true);
    expect(mapWithVariables["Something"]!.length,3);
    expect(mapWithVariables["Something"]!.contains("somethingNamedAfterMe"),true);
    expect(mapWithVariables["Something"]!.contains("complexWeirdVar"),true);
    expect(mapWithVariables["Something"]!.contains("someVariable"),true);
    expect(mapWithVariables["Something"]!.contains("myFunc"),false);
    expect(mapWithVariables["Something"]!.contains("someOtherFunc"),false);

  });
}