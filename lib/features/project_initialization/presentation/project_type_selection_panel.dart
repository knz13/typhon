import 'package:dartz/dartz.dart' show Left, Right;
import 'package:flutter/material.dart';
import 'package:typhon/config/size_config.dart';
import 'package:typhon/config/theme.dart';
import 'package:typhon/features/global_widgets/typhon_button_widget.dart';
import 'package:typhon/features/project_initialization/data/project_model.dart';
import 'package:typhon/features/project_initialization/domain/project_initialization_service.dart';
import 'package:typhon/features/project_initialization/widgets/project_overview_widget.dart';
import 'package:typhon/features/project_initialization/widgets/project_type_widget.dart';
import 'package:typhon/utils/utils.dart';

import '../../../engine.dart';
import '../../../widgets/top_back_button.dart';
import '../../global_widgets/typhon_error_page.dart';
import '../data/project_type.dart';
import 'project_creation_panel.dart';

class ProjectTypeSelectionPanel extends StatefulWidget {
  const ProjectTypeSelectionPanel({super.key});

  @override
  State<ProjectTypeSelectionPanel> createState() =>
      _ProjectTypeSelectionPanelState();
}

class _ProjectTypeSelectionPanelState extends State<ProjectTypeSelectionPanel> {
  List<ProjectType> projectTypes = [];
  String? errorFound;

  bool loadedProjects = false;

  Future<bool> loadProjects() async {
    if (loadedProjects) {
      return true;
    }

    try {
      var value = await ProjectInitializationService.getProjectTypes();

      value.fold((l) {
        loadedProjects = true;
        errorFound = l;
      }, (r) {
        loadedProjects = true;
        projectTypes = r;
      });

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
        title: const Text('Project Type Selection'),
        leading: TopBackButton(onPressed: () {
          Navigator.of(context).pop();
        }),
        actions: const [
          /* TyphonButtonWidget(
            onPressed: () {
            },
            child: const Text(
              "New Project",
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          SizedBox(
            width: getProportionateScreenWidth(20),
          ), */
        ],
      ),
      body: Column(
        children: [
          Text("What type of project would you like to create?",
              style: TextStyle(
                  color: ConfigColors.platinumGray,
                  fontSize: getProportionateScreenWidth(20))),
          SizedBox(
            height: getProportionateScreenHeight(20),
          ),
          FutureBuilder(
              future: loadProjects(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                return TyphonErrorPage(
                  errorText: errorFound,
                  child: Column(
                    children: projectTypes
                        .map((e) => GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) =>
                                        ProjectCreationPanel(type: e)));
                              },
                              child: ProjectTypeWidget(
                                project: e,
                              ),
                            ))
                        .toList(),
                  ),
                );
              }),
        ],
      ),
    );
  }
}
