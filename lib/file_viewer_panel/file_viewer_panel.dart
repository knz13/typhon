import 'package:flutter/material.dart' hide MenuBar hide MenuStyle;

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:typhon/engine.dart';
import 'package:typhon/engine_sub_window.dart';
import 'package:typhon/general_widgets/hierarchy_widget.dart';
import 'package:typhon/general_widgets/spacings.dart';
import 'package:typhon/hierarchy_panel/hierarchy_panel.dart';
import 'package:typhon/main_engine_frontend.dart';
import 'package:typhon/regex_parser.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:watcher/watcher.dart';

import '../general_widgets.dart';

class FileViewerFileToCreate {
  Icon? icon;
  String Function(String)? fileData;

  FileViewerFileToCreate({this.icon, this.fileData});
}

class FileViewerHierarchyData
    extends HierarchyWidgetData<FileViewerHierarchyData> {
  FileViewerHierarchyData({required Directory directory, super.isOpen = false})
      : _directory = directory {
    id = directory.path;
  }

  Directory _directory;

  Directory get directory => _directory;

  set directory(Directory value) {
    id = value.path;
    _directory = value;
  }

  @override
  String getDraggingJSON() {
    return '{"type":"file"}';
  }
}

class FileViewerPanelWindow extends EngineSubWindowData {
  FileViewerPanelWindow()
      : super(
            child: FileViewerPanel(),
            title: "File Viewer",
            onTabSelected: () {
              FileViewerPanel.shouldRefreshFiles.value = true;
            });
}

class FileViewerPanel extends StatefulWidget {
  static ValueNotifier<Directory> currentDirectory =
      ValueNotifier(Directory.current);
  static ValueNotifier<Directory> leftInitialDirectory =
      ValueNotifier(Directory.current);
  static ValueNotifier<bool> reAddWatchers = ValueNotifier(false);
  static ValueNotifier<bool> shouldRefreshFiles = ValueNotifier(false);

  @override
  _FileViewerPanelState createState() => _FileViewerPanelState();
}

class _FileViewerPanelState extends State<FileViewerPanel> {
  List<FileSystemEntity> _files = [];
  List<FileWatcher> _watchers = [];
  FileViewerFileToCreate? tempFileData;
  FocusNode tempFileFocus = FocusNode();

  @override
  void initState() {
    super.initState();

    FileViewerPanel.shouldRefreshFiles.addListener(() {
      if (FileViewerPanel.shouldRefreshFiles.value == true) {
        _refreshFiles();
        FileViewerPanel.shouldRefreshFiles.value = false;
      }
    });

    FileViewerPanel.reAddWatchers.addListener(() {
      if (FileViewerPanel.reAddWatchers.value == true) {
        if (mounted) {
          _watchers.clear();
          _refreshWatchers(FileViewerPanel.currentDirectory.value);
        }

        FileViewerPanel.reAddWatchers.value = false;
      }
    });

    FileViewerPanel.currentDirectory.addListener(() {
      if (mounted) {
        _watchers.clear();
        _refreshWatchers(FileViewerPanel.currentDirectory.value);
        setState(() {
          _refreshFiles();
        });
      }
    });

    FileViewerPanel.leftInitialDirectory.addListener(() {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        if (mounted) {
          setState(() {
            _refreshFiles();
          });
        }
      });
    });
  }

  Future<void> _refreshWatchers(Directory dir) async {
    var dirs = await dir.list().toList();
    for (var file in dirs) {
      if (file is File &&
          [".h", ".cpp", ".c", ".cc"]
              .contains(file.path.substring(file.path.lastIndexOf(".")))) {
        var fileWatcher =
            FileWatcher(file.absolute.path, pollingDelay: Duration(seconds: 2));
        fileWatcher.events.listen((event) {
          Engine.instance.enqueueRecompilation();
        });
        _watchers.add(fileWatcher);
      }
      if (file is Directory) {
        _refreshWatchers(file);
      }
    }
  }

  Future<void> _refreshFiles() async {
    try {
      final files =
          await FileViewerPanel.currentDirectory.value.list().toList();
      if (mounted) {
        setState(() {
          _files = files;
        });
        _buildFolderTree(FileViewerPanel.leftInitialDirectory.value)
            .then((value) {
          setState(() {
            folderHierarchyDataController.objects = value;
          });
        });
      }
    } catch (e) {
      print("Error found while refreshing files: ${e}");
    }
  }

  Future<void> _navigateToDirectory(Directory directory) async {
    FileViewerPanel.currentDirectory.value = directory;
  }

  Future<List<FileViewerHierarchyData>> _buildFolderTree(
      Directory directory) async {
    List<FileViewerHierarchyData> data = [];
    List<FileSystemEntity> directoryData = await directory.list().toList();
    for (final entity in directoryData) {
      if (entity is Directory &&
          !(entity.parent.path ==
                  FileViewerPanel.leftInitialDirectory.value.path &&
              (path.basename(entity.path) == "build" ||
                  path.basename(entity.path) == "includes" ||
                  path.basename(entity.path) == "generated"))) {
        data.add(FileViewerHierarchyData(directory: entity)
          ..children = await _buildFolderTree(entity));
      }
    }
    return data;
  }

  Widget _buildBreadcrumbTrail() {
    final breadcrumbs = <Widget>[
      SizedBox(
        width: 10,
      )
    ];

    final breadCrumbs = path.split(path.relative(
        FileViewerPanel.currentDirectory.value.path,
        from: FileViewerPanel.leftInitialDirectory.value.path));
    var currentPath = FileViewerPanel.leftInitialDirectory.value.path;
    for (final component in breadCrumbs) {
      currentPath = path.join(currentPath, component);
      breadcrumbs.add(GeneralText('>'));
      breadcrumbs.add(SizedBox(width: 4));
      breadcrumbs.add(
        TextButton(
          onPressed: () async {
            final targetDirectory = Directory(currentPath);
            await _navigateToDirectory(targetDirectory);
          },
          child: GeneralText(component),
        ),
      );
    }
    breadcrumbs.add(SizedBox(
      width: 10,
    ));

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: breadcrumbs,
      ),
    );
  }

  double leftWidthPercent = 0.3;
  String hoveringPath = "";
  HierarchyWidgetController<FileViewerHierarchyData>
      folderHierarchyDataController = HierarchyWidgetController([]);

  @override
  Widget build(BuildContext context) {
    if (_files.isEmpty) {
      _refreshFiles();
    }

    return LayoutBuilder(
      builder: (context, constraints) => Row(
        children: [
          Container(
              width: leftWidthPercent * constraints.maxWidth,
              child: HierarchyWidget<FileViewerHierarchyData>(
                controller: folderHierarchyDataController,
                onClick: (data) {
                  _navigateToDirectory(data.directory);
                },
                childBasedOnID: (data) {
                  return Row(
                    children: [
                      Icon(
                        Icons.folder,
                        color: platinumGray,
                        size: 16,
                      ),
                      HorizontalSpacing(10),
                      GeneralText(path.basename(data.directory.path)),
                    ],
                  );
                },
                feedbackBasedOnID: (data) {
                  return GeneralText(path.basename(data.directory.path));
                },
              )),
          MouseRegion(
            cursor: SystemMouseCursors.resizeLeftRight,
            child: Draggable(
              onDragUpdate: (details) {
                if (details.localPosition.dx > 0.15 * constraints.maxWidth &&
                    details.localPosition.dx < 0.85 * constraints.maxWidth) {
                  setState(() {
                    leftWidthPercent =
                        details.localPosition.dx / constraints.maxWidth;
                  });
                }
              },
              feedback: Container(),
              child: Container(
                height: MediaQuery.of(context).size.width,
                width: 2,
                color: Colors.black,
              ),
            ),
          ),

          // Right
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                      color: midGray,
                      border: Border.all(width: 0.2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black,
                          blurRadius: 0.1,
                        )
                      ]),
                  width: MediaQuery.of(context).size.width,
                  child: _buildBreadcrumbTrail(),
                ),
                Expanded(
                  child: GestureDetector(
                    onSecondaryTap: () {
                      showNativeContextMenu(
                          context,
                          MainEngineFrontend.mousePosition.dx,
                          MainEngineFrontend.mousePosition.dy, [
                        if (hoveringPath != "")
                          ContextMenuOption(
                              title: "Open",
                              callback: () {
                                launchUrl(Uri.parse("file:" +
                                    path.join(
                                        FileViewerPanel.currentDirectory.value
                                            .absolute.path,
                                        hoveringPath)));
                              }),
                        ContextMenuOption(
                            title: "Open Folder In Explorer",
                            callback: () {
                              launchUrl(Uri.parse("file:" +
                                  FileViewerPanel
                                      .currentDirectory.value.absolute.path));
                            }),
                        ContextMenuSeparator(),
                        ContextMenuOption(title: "Create", subOptions: [
                          ContextMenuOption(
                              title: "Empty GameObject",
                              callback: () {
                                setState(() {
                                  tempFileData = FileViewerFileToCreate(
                                      fileData: (str) => """#pragma once
#include <iostream>
#include "engine.h"

class ${str} : public DerivedFromGameObject<${str}
  //Here you can add the class traits you wish to use
  //for example: Traits::HasUpdate<${str}>,Traits::HasPosition...
  
  > {
private:
  //Add your private variables here

public:
  //Function called when the object is created
  void Create() {};

  //Function called when the object is destroyed
  void Destroy() {};

};
""");
                                });
                              }),
                        ]),
                        if (hoveringPath != "" &&
                            path.basename(hoveringPath) != "entry.h")
                          ContextMenuSeparator(),
                        if (hoveringPath != "" &&
                            path.basename(hoveringPath) != "entry.h")
                          ContextMenuOption(
                              title: "Delete",
                              callback: () {
                                File(path.join(
                                        FileViewerPanel.currentDirectory.value
                                            .absolute.path,
                                        hoveringPath))
                                    .deleteSync(recursive: true);
                                _refreshFiles();
                              })
                      ]);
                    },
                    child: ListView.separated(
                      separatorBuilder: (BuildContext context, int index) =>
                          Divider(),
                      itemCount: _files.length + (tempFileData == null ? 0 : 1),
                      itemBuilder: (BuildContext context, int index) {
                        if (tempFileData != null && index == _files.length) {
                          tempFileFocus.requestFocus();
                          return ListTile(
                            leading: tempFileData!.icon ?? Icon(MdiIcons.file),
                            title: TextField(
                              focusNode: tempFileFocus,
                              onSubmitted: (value) {
                                File file = File(path.join(
                                    FileViewerPanel.currentDirectory.value.path,
                                    "$value.h"));

                                file.createSync();

                                FileViewerPanel.reAddWatchers.value = true;

                                file.writeAsStringSync(
                                    tempFileData!.fileData != null
                                        ? tempFileData!.fileData!.call(value)
                                        : "");

                                _refreshFiles();
                                _refreshWatchers(
                                    FileViewerPanel.currentDirectory.value);

                                setState(() {
                                  tempFileData = null;
                                });
                              },
                              onTapOutside: (event) {
                                setState(() {
                                  tempFileData = null;
                                });
                              },
                              autofocus: true,
                            ),
                          );
                        }
                        final entity = _files[index];
                        return MouseRegion(
                          onEnter: (event) {
                            hoveringPath = _files.elementAt(index).path;
                          },
                          onExit: (event) {
                            hoveringPath = "";
                          },
                          child: ListTile(
                            leading: entity is File
                                ? Icon(MdiIcons.file)
                                : Icon(Icons.folder),
                            title: GeneralText(path.basename(entity.path)),
                            onTap: () async {
                              if (entity is File) {
                              } else if (entity is Directory) {
                                await _navigateToDirectory(entity);
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
