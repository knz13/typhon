import 'dart:io';

import 'package:typhon/regex_parser.dart';
import 'package:test/test.dart';

void main() {
  test('Parsing cpp files', () {
    String fileData = File("cpp_library/src/mono_manager.h").readAsStringSync();

    var map = CPPParser.getClassesProperties(fileData);

    expect(map.containsKey("MonoManager"),true);
    expect(map["MonoManager"]["variables"]!.length, 1);
    expect(map["MonoManager"]["variables"]!.contains("_initialized"), true);
  });
  test('Parsing complex file', () {
    String fileData = File("cpp_library/src/game_object.h").readAsStringSync();

    var map = CPPParser.getClassesProperties(fileData);
    expect(map.containsKey("GameObject"),true);
    expect(map["GameObject"]["variables"]!.length,4);
    expect(map["GameObject"]["variables"]!.contains("className"),true);
    expect(map["GameObject"]["variables"]!.contains("onDestroyEvent"),true);
    expect(map["GameObject"]["variables"]!.contains("handle"),true);
    expect(map["GameObject"]["variables"]!.contains("name"),true);
    
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

    var map = CPPParser.getClassesProperties(fileData);
    expect(map.containsKey("Something"),true);
    expect(map["Something"]["variables"]!.length,2);
    expect(map["Something"]["variables"]!.contains("somethingNamedAfterMe"),true);
    expect(map["Something"]["variables"]!.contains("someVariable"),true);
    expect(map["Something"]["variables"]!.contains("myFunc"),false);
    expect(map["Something"]["variables"]!.contains("someOtherFunc"),false);

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

    var map = CPPParser.getClassesProperties(fileData);
    expect(map.containsKey("Something"),true);
    expect(map["Something"]["variables"]!.length,3);
    expect(map["Something"]["variables"]!.contains("somethingNamedAfterMe"),true);
    expect(map["Something"]["variables"]!.contains("complexWeirdVar"),true);
    expect(map["Something"]["variables"]!.contains("someVariable"),true);
    expect(map["Something"]["variables"]!.contains("myFunc"),false);
    expect(map["Something"]["variables"]!.contains("someOtherFunc"),false);

  });

  test('Parsing class with inheritance',() {
    String fileData = """
#include <iostream>
#include "../engine.h>


template<typename A>
class Something : public DerivedFromGameObject<Something<A>,
Traits::SomeTrait,Traits::SomeOtherTrait<Something<A>>>,
SomethingOrOther,
public AnotherClass {
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


  var map = CPPParser.getClassesProperties(fileData);


  expect(map["Something"].containsKey("inheritance"),true);
  expect((map["Something"]["inheritance"] is List),true);
  expect((map["Something"]["inheritance"] as List).length == 3,true);
  expect((map["Something"]["inheritance"] as List).contains("DerivedFromGameObject"),true);
  expect((map["Something"]["inheritance"] as List).contains("SomethingOrOther"),true);
  expect((map["Something"]["inheritance"] as List).contains("AnotherClass"),true);



  });
}