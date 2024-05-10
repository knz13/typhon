import 'package:flutter/material.dart';
import 'package:typhon/config/size_config.dart';
import 'package:typhon/config/theme.dart';
import 'package:typhon/features/global_widgets/typhon_button_widget.dart';
import 'package:typhon/features/project_initialization/data/project_model.dart';
import 'package:typhon/features/project_initialization/domain/project_initialization_service.dart';
import 'package:typhon/features/project_initialization/presentation/project_type_selection_panel.dart';
import 'package:typhon/features/project_initialization/widgets/project_overview_widget.dart';

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
  bool unpackingAssets = false;
  int progress = 0;
  int total = 0;

  Future<bool> loadProjects() async {
    if (loadedProjects || unpackingAssets) {
      return true;
    }

    try {
      // unpack the assets

      setState(() {
        unpackingAssets = true;
      });

      await ProjectInitializationService.unpackLibAssets(
          onProgress: (progress, total) {
        setState(() {
          this.progress = progress;
          this.total = total;
        });
      });

      var value = await ProjectInitializationService.getProjects();

      value.fold((l) {
        loadedProjects = true;
        errorFound = l;
      }, (r) {
        loadedProjects = true;
        projects = r;
      });

      unpackingAssets = false;

      return true;
    } catch (e) {
      loadedProjects = true;
      setState(() {
        unpackingAssets = false;
      });
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
              setState(() {
                loadedProjects = false;
                projects = [];
                errorFound = null;
                unpackingAssets = false;
              });
            },
            child: const Text(
              "Reload",
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          SizedBox(
            width: getProportionateScreenWidth(20),
          ),
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
            if (!snapshot.hasData || unpackingAssets) {
              return SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Unpacking Assets - $progress/$total",
                        style: TextStyle(
                            color: ConfigColors.platinumGray,
                            fontSize: getProportionateScreenWidth(20))),
                    CircularProgressIndicator(),
                  ],
                ),
              );
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
