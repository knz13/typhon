import 'dart:core';

class Tuple2<T1, T2> {
  final T1 item1;
  final T2 item2;

  Tuple2(this.item1, this.item2);

  @override
  String toString() {
    return "$item1 : $item2";
  }

  @override
  bool operator ==(Object other) =>
      other is Tuple2<T1, T2> &&
      other.item1 == this.item1 &&
      other.item2 == this.item2;

  @override
  // ignore: unnecessary_overrides
  int get hashCode => super.hashCode;
}

class CPPParser {
  static String removeComments(String text) {
    text = text.replaceAll(RegExp(r'/\*.*?\*/', dotAll: true), '');
    text = text.replaceAll(RegExp(r'//.*?\n'), '');
    return text;
  }

  static String removeContentBetweenAngleBrackets(String input) {
    RegExp pattern = RegExp(r'<[^<>]*>', multiLine: true, dotAll: true);
    String output;

    while ((output = input.replaceAll(pattern, '')) != input) {
      input = output;
    }

    return output;
  }

  static List<String> extractBaseClasses(String fileContent, String className) {
    // RegExp pattern to match class definition with inheritance
    final pattern = RegExp(r'class\s+' + className + r'\s*:\s*([\s\S]*?)\{',
        caseSensitive: false);
    final match = pattern.firstMatch(fileContent);
    if (match == null) {
      return [];
    }

    var baseClassesStr = match.group(1);
    if (baseClassesStr == null) {
      return [];
    }
    baseClassesStr = removeContentBetweenAngleBrackets(baseClassesStr);
    final baseClasses = baseClassesStr.split(RegExp(r'\s*,\s*'));

    // RegExp pattern to match only the class names
    final classNamePattern =
        RegExp(r'\b(?:public\s+|private\s+|protected\s+)?([\w:]+)\b');

    return baseClasses
        .map((baseClass) =>
            classNamePattern.firstMatch(baseClass)?.group(1) ?? "")
        .where((className) => className != "")
        .toList();
  }

  static Map<String, dynamic> getClassesProperties(String text) {
    text = removeComments(text);

    Map<String, String> classesText = {};
    Map<String, List<String>> classesInheritance = {};
    List<Tuple2<String, int>> classNames = [];

    RegExp classNameExp = RegExp(r'class .*? {');
    for (Match match in classNameExp.allMatches(text)) {
      classNames.add(Tuple2(text.substring(match.start + 6).split(' ')[0],
          text.substring(match.start).indexOf("{") + match.start - 1));
    }

    classNameExp = RegExp(r'class .*? :');
    for (Match match in classNameExp.allMatches(text)) {
      classNames.add(Tuple2(text.substring(match.start + 6).split(' ')[0],
          text.substring(match.start).indexOf("{") + match.start - 1));
    }

    var seen = <int>{};
    classNames =
        classNames.where((element) => seen.add(element.item2)).toList();

    classNames.sort((a, b) {
      return a.item2.compareTo(b.item2);
    });

    //getting class inheritance
    for (String className in classNames.map(
      (e) => e.item1,
    )) {
      classesInheritance[className] = extractBaseClasses(text, className);
    }

    for (int i = 0; i < classNames.length; i++) {
      String className = classNames[i].item1;
      int classStart = classNames[i].item2;

      int initialPosition = classStart;
      int endPosition = -1;
      if (i == classNames.length - 1) {
        endPosition = text.length - 1;
      } else {
        endPosition = classNames[i + 1].item2;
      }
      String classText = text.substring(initialPosition + 1, endPosition);

      List<Tuple2<int, String>> scopeStarts = [];
      List<Tuple2<int, String>> scopeEnds = [];
      RegExp openScopeExp = RegExp(r'{');
      RegExp closeScopeExp = RegExp(r'}');

      for (Match match in openScopeExp.allMatches(classText)) {
        scopeStarts.add(Tuple2(match.start, 'open'));
      }

      for (Match match in closeScopeExp.allMatches(classText)) {
        scopeEnds.add(Tuple2(match.start, 'close'));
      }

      List<Tuple2<int, String>> scopes = scopeStarts + scopeEnds;
      scopes.sort((a, b) => a.item1.compareTo(b.item1));

      int finalPosition = -1;
      int scopesOpened = 0;

      for (int scopeIndex = 0; scopeIndex < scopes.length; scopeIndex++) {
        if (scopes[scopeIndex].item2 == 'open') {
          scopesOpened++;
        }
        if (scopes[scopeIndex].item2 == 'close') {
          if (scopesOpened == 1) {
            finalPosition = scopes[scopeIndex].item1;
            break;
          }
          scopesOpened--;
        }
      }

      classText = classText.substring(0, finalPosition + 1);
      classesText[className] = classText;
    }

    var variables = extractVariableFromClassesText(classesText);

    Map<String, dynamic> finalMap = {};

    for (String className in classesText.keys) {
      finalMap[className] = {
        "variables": variables[className]!,
        "class_text": classesText[className]!,
        "inheritance": classesInheritance[className]!
      };
    }

    return finalMap;
  }

  static Map<String, List<String>> extractVariableFromClassesText(
      Map<String, String> classes) {
    Map<String, List<String>> classVariables = {};

    classes.forEach((className, classText) {
      List<String> variables = [];

      classText = classText.replaceAll('\n', '');

      RegExp friendsExp = RegExp(r'friend.*?;');
      classText = classText.replaceAll(friendsExp, '');

      List<String> functionImpls = [];
      int stack = 0;
      int start = -1;
      for (int i = 1; i < classText.length - 1; i++) {
        if (classText[i] == '{') {
          if (stack == 0) {
            start = i;
          }
          stack++;
        } else if (classText[i] == '}') {
          stack--;
          if (stack == 0 && start != -1) {
            functionImpls.add(classText.substring(start, i + 1));
            start = -1;
          }
        }
      }

      for (final functionImpl in functionImpls) {
        classText = classText.replaceAll(functionImpl, ';');
      }

      String classTextWeird =
          '${'-' * 100}\n\n$classText $className\n\n${'-' * 100}';

      List<String> extractVariableNames(String code, String nameOfClass) {
        List<String> variableNames = [];

        code = code.replaceAll(RegExp(r'//.*'), '');

        List<String> statements = code.split(RegExp(r';|(?<!:):(?!:)'));

        for (String statement in statements) {
          statement = statement.trim();

          if (statement.isEmpty) {
            continue;
          }

          if (statement.contains('static') ||
              statement.contains('public') ||
              statement.contains('private') ||
              statement.contains('protected') ||
              statement.contains('override')) {
            continue;
          }

          if (statement.contains('::')) {
            statement = statement.replaceAll('::', '');
          }

          if (statement.contains(" $nameOfClass")) {
            continue;
          }

          String name = '';

          RegExp functionExp = RegExp(r'\w+\s+(\w+)\s*\(');
          RegExpMatch? functionMatch = functionExp.firstMatch(statement);

          if (functionMatch != null) {
            name = functionMatch.group(1)!;
          } else {
            RegExp variableExp = RegExp(
                r'(?:[\w:]+(?:<[^>]*>)?|(?:\w+::)*\w+)(?:\s*[\*&]+)?(?:\s*\w+)?\s+([\w]+)');
            RegExpMatch? variableMatch = variableExp.firstMatch(statement);
            if (variableMatch != null) {
              name = variableMatch.group(1)!;
            }
          }

          if (name.isEmpty) {
            continue;
          }

          if (statement.substring(statement.indexOf(name)).contains('(') &&
              !statement.contains('=')) {
            continue;
          }

          variableNames.add(name);
        }

        return variableNames;
      }

      variables = extractVariableNames(classTextWeird, className);
      classVariables[className] = variables;
    });

    return classVariables;
  }
}
