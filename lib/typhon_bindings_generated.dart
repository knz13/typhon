// ignore_for_file: always_specify_types
// ignore_for_file: camel_case_types
// ignore_for_file: constant_identifier_names

// AUTO GENERATED FILE, DO NOT EDIT.
//
// Generated by `package:ffigen`.
import 'dart:ffi' as ffi;

/// Bindings for `c_sharp_interface/src/typhon.h`.
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

  int initializeCppLibrary() {
    return _initializeCppLibrary();
  }

  late final _initializeCppLibraryPtr =
      _lookup<ffi.NativeFunction<ffi.Int Function()>>('initializeCppLibrary');
  late final _initializeCppLibrary =
      _initializeCppLibraryPtr.asFunction<int Function()>();

  void onMouseMove(
    double positionX,
    double positionY,
  ) {
    return _onMouseMove(
      positionX,
      positionY,
    );
  }

  late final _onMouseMovePtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(ffi.Double, ffi.Double)>>(
          'onMouseMove');
  late final _onMouseMove =
      _onMouseMovePtr.asFunction<void Function(double, double)>();

  void onKeyboardKeyDown(
    int input,
  ) {
    return _onKeyboardKeyDown(
      input,
    );
  }

  late final _onKeyboardKeyDownPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(ffi.Int64)>>(
          'onKeyboardKeyDown');
  late final _onKeyboardKeyDown =
      _onKeyboardKeyDownPtr.asFunction<void Function(int)>();

  void onKeyboardKeyUp(
    int input,
  ) {
    return _onKeyboardKeyUp(
      input,
    );
  }

  late final _onKeyboardKeyUpPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(ffi.Int64)>>(
          'onKeyboardKeyUp');
  late final _onKeyboardKeyUp =
      _onKeyboardKeyUpPtr.asFunction<void Function(int)>();

  void onUpdateCall(
    double dt,
  ) {
    return _onUpdateCall(
      dt,
    );
  }

  late final _onUpdateCallPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(ffi.Double)>>(
          'onUpdateCall');
  late final _onUpdateCall =
      _onUpdateCallPtr.asFunction<void Function(double)>();

  void passProjectPath(
    ffi.Pointer<ffi.Char> path,
  ) {
    return _passProjectPath(
      path,
    );
  }

  late final _passProjectPathPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<ffi.Char>)>>(
          'passProjectPath');
  late final _passProjectPath =
      _passProjectPathPtr.asFunction<void Function(ffi.Pointer<ffi.Char>)>();

  void attachEnqueueRender(
    EnqueueObjectRender func,
  ) {
    return _attachEnqueueRender(
      func,
    );
  }

  late final _attachEnqueueRenderPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(EnqueueObjectRender)>>(
          'attachEnqueueRender');
  late final _attachEnqueueRender =
      _attachEnqueueRenderPtr.asFunction<void Function(EnqueueObjectRender)>();

  void unloadLibrary() {
    return _unloadLibrary();
  }

  late final _unloadLibraryPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function()>>('unloadLibrary');
  late final _unloadLibrary = _unloadLibraryPtr.asFunction<void Function()>();

  void createObjectFromClassID(
    int classID,
  ) {
    return _createObjectFromClassID(
      classID,
    );
  }

  late final _createObjectFromClassIDPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(ffi.Int64)>>(
          'createObjectFromClassID');
  late final _createObjectFromClassID =
      _createObjectFromClassIDPtr.asFunction<void Function(int)>();

  ClassesArray getInstantiableClasses() {
    return _getInstantiableClasses();
  }

  late final _getInstantiableClassesPtr =
      _lookup<ffi.NativeFunction<ClassesArray Function()>>(
          'getInstantiableClasses');
  late final _getInstantiableClasses =
      _getInstantiableClassesPtr.asFunction<ClassesArray Function()>();
}

typedef EnqueueObjectRender = ffi.Pointer<
    ffi.NativeFunction<
        ffi.Void Function(
            ffi.Double,
            ffi.Double,
            ffi.Int64,
            ffi.Int64,
            ffi.Int64,
            ffi.Int64,
            ffi.Double,
            ffi.Double,
            ffi.Double,
            ffi.Double)>>;

class ClassesArray extends ffi.Struct {
  external ffi.Pointer<ffi.Int64> array;

  external ffi.Pointer<ffi.Pointer<ffi.Char>> stringArray;

  @ffi.Int64()
  external int stringArraySize;

  @ffi.Int64()
  external int size;
}
