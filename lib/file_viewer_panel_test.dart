
import 'package:flutter/material.dart' hide MenuBar hide MenuStyle;

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import 'general_widgets.dart';



class FileViewerPanelGPT extends StatefulWidget {
  @override
  _FileViewerPanelGPTState createState() => _FileViewerPanelGPTState();
}

class _FileViewerPanelGPTState extends State<FileViewerPanelGPT> {
  Directory? _currentDirectory;
  Directory? _initialDirectory;
  List<FileSystemEntity> _files = [];

  @override
  void initState() {
    super.initState();

    

    _refreshFiles();
  }




  Future<void> _refreshFiles() async {
    if(_currentDirectory == null){
      
      _currentDirectory = await getApplicationDocumentsDirectory();
      Directory directory = Directory(path.join(_currentDirectory!.path,"Projects","Project_Teste","Assets"));
      if (!(await directory.exists())) {
        await directory.create(recursive: true);
      }
      _currentDirectory = directory;

    }
    if(_initialDirectory == null){
      _initialDirectory = Directory(path.normalize(path.join(_currentDirectory!.path,'../')));
    }
    final files = await _currentDirectory!.list().toList();
    if(mounted){

    setState(() {
      _files = files;
    });
    }
  }

  Future<void> _navigateToDirectory(Directory directory) async {
    setState(() {
      _currentDirectory = directory;
    });
    await _refreshFiles();
  }

  Future<void> _showFileContents(File file) async {
    final contents = await file.readAsString();
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(title: Text(file.path)),
        body: SingleChildScrollView(
          child: Text(contents),
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
            title: Text(path.basename(entity.path)),
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
  if (_initialDirectory == null || _currentDirectory == null) {
    return SizedBox.shrink();
  }

  final breadcrumbs = <Widget>[  SizedBox(width: 10,)  ];

  
  final breadCrumbs = path.split(path.relative(_initialDirectory!.path,from: _currentDirectory!.path));
  var currentPath = _initialDirectory!.path;
  for (final component in breadCrumbs) {
    currentPath = path.join(currentPath, component);
    breadcrumbs.add(Text('>'));
    breadcrumbs.add(SizedBox(width: 4));
    breadcrumbs.add(
      TextButton(
        onPressed: () async {
          final targetDirectory = Directory(currentPath);
          await _navigateToDirectory(targetDirectory);
        },
        child: Text(component),
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

  double leftWidthPercent = 0.5;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context,constraints) => Row(
        children: [
          if (_initialDirectory != null)
            Container(
              width: leftWidthPercent*constraints.maxWidth,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFolderTree(_initialDirectory!),
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
                        title: Text(path.basename(entity.path)),
                        subtitle: entity is File
                            ? Text('${(entity.lengthSync() / 1024).toStringAsFixed(2)} KB')
                            : null,
                        onTap: () async {
                          if (entity is File) {
                            await _showFileContents(entity);
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