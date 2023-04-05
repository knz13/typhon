import 'package:flutter/material.dart' hide MenuBar hide MenuStyle;

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:typhon/engine.dart';
import 'package:url_launcher/url_launcher.dart';

import 'general_widgets.dart';

class FileViewerPanel extends StatefulWidget {
  static ValueNotifier<Directory> currentDirectory = ValueNotifier(Directory.current);
  static ValueNotifier<Directory> leftInitialDirectory = ValueNotifier(Directory.current);

  @override
  _FileViewerPanelState createState() => _FileViewerPanelState();
}

class _FileViewerPanelState extends State<FileViewerPanel> {
  List<FileSystemEntity> _files = [];

  @override
  void initState() {
    super.initState();


    FileViewerPanel.currentDirectory.addListener(() {
      if(mounted){
        setState(() {
          _refreshFiles();
        });
      }
    });

    FileViewerPanel.leftInitialDirectory.addListener(() {
      if(mounted) {
        setState(() {
          _refreshFiles();
        });
      }
    });

    _refreshFiles();
  }

  Future<void> _refreshFiles() async {
    final files = await FileViewerPanel.currentDirectory.value.list().toList();
    if(mounted){
    setState(() {
      _files = files;
    });
    }
  }

  Future<void> _navigateToDirectory(Directory directory) async {
    FileViewerPanel.currentDirectory.value = directory;
  }

  Future<void> _showFileContents(File file) async {
    final contents = await file.readAsString();
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(title: GeneralText(file.path)),
        body: SingleChildScrollView(
          child: GeneralText(contents),
        ),
      ),
    ));
  }

  Widget _buildFolderTree(Directory directory) {
  return FutureBuilder<List<FileSystemEntity>>(
    future: directory.list().toList(),
    builder: (BuildContext context, AsyncSnapshot<List<FileSystemEntity>> snapshot) {
      if (!snapshot.hasData) {
        return Container();
      }
      final children = <Widget>[];
      for (final entity in snapshot.data!) {
        if (entity is Directory) {
          bool isExpanded = false;
          children.add(ExpansionTile(
            collapsedIconColor: platinumGray,
            iconColor: platinumGray,
            textColor: platinumGray,
            collapsedTextColor: platinumGray,
            leading: Icon(Icons.folder),
            title: GeneralText(path.basename(entity.path)),
            onExpansionChanged: (isExpanded) {
              if (isExpanded) {
                _navigateToDirectory(entity);
              }
            },
            children: [_buildFolderTree(entity)],
            initiallyExpanded: isExpanded,
          ));
        }
      }
      return Column(children: children);
    },
  );
}

Widget _buildBreadcrumbTrail() {

  final breadcrumbs = <Widget>[  SizedBox(width: 10,)  ];

  
  final breadCrumbs = path.split(path.relative(FileViewerPanel.currentDirectory.value.path,from: FileViewerPanel.leftInitialDirectory.value.path));
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
  breadcrumbs.add(SizedBox(width: 10,));

  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: breadcrumbs,
    ),
  );
}

  double leftWidthPercent = 0.3;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context,constraints) => Row(
        children: [
          Container(
            width: leftWidthPercent*constraints.maxWidth,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFolderTree(FileViewerPanel.leftInitialDirectory.value),
                ],
              ),
            ),
          ),
          MouseRegion(
            cursor: SystemMouseCursors.resizeLeftRight,
            child: Draggable(
              onDragUpdate: (details) {
                if(details.localPosition.dx > 0.15*constraints.maxWidth && details.localPosition.dx < 0.85*constraints.maxWidth) {
                  setState(() {
                    leftWidthPercent = details.localPosition.dx/constraints.maxWidth;
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
                    boxShadow: [BoxShadow(
                      color: Colors.black,
                      blurRadius: 0.1,
                    )]
                  ),
                  width: MediaQuery.of(context).size.width,
                  child: _buildBreadcrumbTrail(),
                ),
                Expanded(
                  child: ListView.separated(
                    separatorBuilder: (BuildContext context, int index) => Divider(),
                    itemCount: _files.length,
                    itemBuilder: (BuildContext context, int index) {
                      final entity = _files[index];
                      return ListTile(
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
                      );
                    },
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