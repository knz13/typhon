import 'package:flutter/material.dart';
import 'package:typhon/config/size_config.dart';
import 'package:typhon/config/theme.dart';
import 'package:typhon/features/global_widgets/typhon_button_widget.dart';
import 'package:typhon/features/project_choice_panel/data/project_model.dart';
import 'package:typhon/features/project_choice_panel/widgets/project_overview_widget.dart';

import '../../../engine.dart';
import '../../global_widgets/typhon_error_page.dart';

class ProjectChoicePanel extends StatefulWidget {
  const ProjectChoicePanel({super.key});

  @override
  State<ProjectChoicePanel> createState() => _ProjectChoicePanelState();
}

class _ProjectChoicePanelState extends State<ProjectChoicePanel> {
  List<ProjectModel> projects = [];
  String? errorFound;

  bool loadedProjects = false;

  Future<bool> loadProjects() async {
    if (loadedProjects) {
      return true;
    }

    try {
      projects = await Engine.instance.getProjectsJSON();

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
