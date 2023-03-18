// ignore_for_file: always_specify_types
// ignore_for_file: camel_case_types
// ignore_for_file: constant_identifier_names

// AUTO GENERATED FILE, DO NOT EDIT.
//
// Generated by `package:ffigen`.
import 'dart:ffi' as ffi;

/// Bindings for `lua_binding_library/src/typhon.h`.
/// Regenerate bindings with `dart run ffigen --config ffigen.yaml`.
///
class TyphonBindings {
  /// Holds the symbol lookup function.
  final ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName)
      _lookup;

  /// The symbols are looked up in [dynamicLibrary].
  TyphonBindings(ffi.DynamicLibrary dynamicLibrary)
      : _lookup = dynamicLibrary.lookup;

  /// The symbols are looked up with [lookup].
  TyphonBindings.fromLookup(
      ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName)
          lookup)
      : _lookup = lookup;

  void registerAddGameObjectFunction(
    AddGameObjectFunction func,
  ) {
    return _registerAddGameObjectFunction(
      func,
    );
  }

  late final _registerAddGameObjectFunctionPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(AddGameObjectFunction)>>(
          'registerAddGameObjectFunction');
  late final _registerAddGameObjectFunction = _registerAddGameObjectFunctionPtr
      .asFunction<void Function(AddGameObjectFunction)>();

  int loadScriptFromString(
    ffi.Pointer<ffi.Char> string,
  ) {
    return _loadScriptFromString(
      string,
    );
  }

  late final _loadScriptFromStringPtr =
      _lookup<ffi.NativeFunction<ffi.Int Function(ffi.Pointer<ffi.Char>)>>(
          'loadScriptFromString');
  late final _loadScriptFromString = _loadScriptFromStringPtr
      .asFunction<int Function(ffi.Pointer<ffi.Char>)>();

  void registerRemoveGameObjectFunction(
    RemoveGameObjectFunction func,
  ) {
    return _registerRemoveGameObjectFunction(
      func,
    );
  }

  late final _registerRemoveGameObjectFunctionPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(RemoveGameObjectFunction)>>(
          'registerRemoveGameObjectFunction');
  late final _registerRemoveGameObjectFunction =
      _registerRemoveGameObjectFunctionPtr
          .asFunction<void Function(RemoveGameObjectFunction)>();

  void registerPrintToEditorWindow(
    PrintToEditorWindow func,
  ) {
    return _registerPrintToEditorWindow(
      func,
    );
  }

  late final _registerPrintToEditorWindowPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(PrintToEditorWindow)>>(
          'registerPrintToEditorWindow');
  late final _registerPrintToEditorWindow = _registerPrintToEditorWindowPtr
      .asFunction<void Function(PrintToEditorWindow)>();
}

typedef AddGameObjectFunction
    = ffi.Pointer<ffi.NativeFunction<ffi.Int Function(ffi.Int)>>;
typedef RemoveGameObjectFunction
    = ffi.Pointer<ffi.NativeFunction<ffi.Int Function(ffi.Int)>>;
typedef PrintToEditorWindow
    = ffi.Pointer<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<ffi.Char>)>>;
