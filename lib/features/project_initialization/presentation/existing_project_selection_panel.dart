import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:typhon/config/size_config.dart';
import 'package:typhon/config/theme.dart';
import 'package:typhon/features/global_widgets/typhon_button_widget.dart';
import 'package:typhon/features/project_initialization/data/project_model.dart';
import 'package:typhon/features/project_initialization/domain/project_initialization_service.dart';
import 'package:typhon/features/project_initialization/presentation/project_type_selection_panel.dart';
import 'package:typhon/features/project_initialization/widgets/project_overview_widget.dart';
import 'package:typhon/utils/websocket_manager.dart';

import '../../../engine.dart';
import '../../global_widgets/typhon_error_page.dart';

class ExistingProjectSelectionPanel extends StatefulWidget {
  const ExistingProjectSelectionPanel({super.key});

  @override
  State<ExistingProjectSelectionPanel> createState() =>
      _ExistingProjectSelectionPanelState();
}

class _ExistingProjectSelectionPanelState
    extends State<ExistingProjectSelectionPanel> {
  List<ProjectModel> projects = [];
  String? errorFound;

  bool loadedProjects = false;
  WebSocketManager? webSocketManager;

  Future<bool> loadProjects() async {
    if (loadedProjects) {
      return true;
    }

    try {
      var value = await ProjectInitializationService.getProjects();

      value.fold((l) {
        loadedProjects = true;
        errorFound = l;
      }, (r) {
        loadedProjects = true;
        projects = r;
      });

      // try creating socket server

      webSocketManager = WebSocketManager("ws://0.0.0.0:9090",
          onNumberInternalClientsChanged: (int number) {});

      // RGB image with 1920x1080 resolution

      var image = List.generate(800 * 400 * 3, (index) => 0.0);

      var imageUint8List =
          Uint8List.fromList(image.map((e) => e.toInt()).toList());

      print("Image size: ${imageUint8List.length} bytes");

      await webSocketManager!.initialize();

      // send image to server and check time
      
      var start = DateTime.now().millisecondsSinceEpoch;

      webSocketManager!.sendMessage(imageUint8List);

      /* // send a lot of data to check for server crash
      int tries = 0;
      while (tries < 50) {
        print("Trying ${tries++}");
        // sending 100kb of data
        webSocketManager!.sendMessage(Uint8List(1024 * 100));
        await Future.delayed(const Duration(milliseconds: 50));
      }
 */
      return true;
    } catch (e) {
      loadedProjects = true;
      errorFound = e.toString();
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ConfigColors.platinumGray,
        title: const Text('Project Choice Panel'),
        actions: [
          TyphonButtonWidget(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const ProjectTypeSelectionPanel()));
            },
            child: const Text(
              "New Project",
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          SizedBox(
            width: getProportionateScreenWidth(20),
          ),
        ],
      ),
      body: FutureBuilder(
          future: loadProjects(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            return TyphonErrorPage(
              errorText: errorFound,
              child: Column(
                children: projects
                    .map((e) => ProjectOverviewWidget(
                          project: e,
                        ))
                    .toList(),
              ),
            );
          }),
    );
  }
}
