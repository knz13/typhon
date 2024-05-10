import 'package:flutter/material.dart';
import 'package:typhon/features/engine_frontend/domain/engine_frontend_service.dart';
import 'package:typhon/features/project_initialization/data/project_model.dart';

import '../widgets/inspector_panel/inspector_panel.dart';

class EngineFrontend extends StatefulWidget {
  static Offset mousePosition = Offset.zero;

  const EngineFrontend({super.key, required this.project});

  final ProjectModel project;

  @override
  State<EngineFrontend> createState() => _EngineFrontendState();
}

class _EngineFrontendState extends State<EngineFrontend> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();

    InspectorPanelWindow.data.value = InspectorPanelData();
  }

  bool loaded = false;

  Future<bool> loadProject() async {
    if (loaded) return true;

    var value = await EngineFrontendService.loadProject(widget.project);

    loaded = true;

    return true;
  }

  Widget buildMainFrontend() {
    return MouseRegion(
      child: Scaffold(
          backgroundColor: Colors.transparent,
          body: FutureBuilder(
              future: loadProject(),
              builder: (context, snapshot) {
                return Container();
              }) /* EngineSubWindow(
            division: SubWindowDivision.left,
            mainChildProportion: 0.75,
            mainSubWindow: EngineSubWindow(
              mainChildProportion: 0.7,
              division: SubWindowDivision.top,
              mainSubWindow: EngineSubWindow(
                division: SubWindowDivision.right,
                mainChildProportion: 0.75,
                mainSubWindow: EngineSubWindow(tabs: [SceneViewerWindow()]),
                splitSubWindow: EngineSubWindow(
                  tabs: [HierarchyPanelWindow()],
                ),
              ),
              splitSubWindow: EngineSubWindow(
                tabs: [FileViewerPanelWindow(), ConsolePanelSubWindow()],
              ),
            ),
            splitSubWindow: EngineSubWindow(
              tabs: [InspectorPanelWindow()],
            ),
          ) */
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: MouseRegion(
          onHover: (ev) {
            EngineFrontend.mousePosition = ev.position;
          },
          child: buildMainFrontend()),
    );
  }
}
