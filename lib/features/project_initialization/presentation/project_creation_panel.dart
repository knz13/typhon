import 'dart:io';

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
import 'package:typhon/widgets/customized_text_field.dart';
import 'package:typhon/widgets/top_back_button.dart';

import '../../../engine.dart';
import '../../global_widgets/typhon_error_page.dart';
import '../data/project_type.dart';
import 'package:file_picker/file_picker.dart';

class ProjectCreationPanel extends StatefulWidget {
  const ProjectCreationPanel({super.key, required this.type});

  final ProjectType type;

  @override
  State<ProjectCreationPanel> createState() => _ProjectCreationPanelState();
}

class _ProjectCreationPanelState extends State<ProjectCreationPanel> {
  String? errorFound;
  String? projectName;
  String? projectPath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ConfigColors.platinumGray,
        title: const Text('Project Creation'),
        leading: TopBackButton(onPressed: () {
          Navigator.of(context).pop();
        }),
        actions: const [],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text("Project Name",
                style: TextStyle(
                    color: ConfigColors.platinumGray,
                    fontSize: getProportionateScreenWidth(20))),
            SizedBox(
              height: getProportionateScreenHeight(10),
            ),
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5), color: Colors.white),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CustomizedTextField(onChanged: (v) {
                  setState(() {
                    projectName = v;
                  });
                }),
              ),
            ),
            SizedBox(
              height: getProportionateScreenHeight(20),
            ),
            Text("Project Path",
                style: TextStyle(
                    color: ConfigColors.platinumGray,
                    fontSize: getProportionateScreenWidth(20))),
            SizedBox(
              height: getProportionateScreenHeight(10),
            ),
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5), color: Colors.white),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TyphonButtonWidget(
                  onPressed: () async {
                    

                                                      var path = await FilePicker
                                                          .platform
                                                          .getDirectoryPath(
                                                              dialogTitle:
                                                                  "Select Project Directory");
                                                      setState(() {
                                                        projectPath =
                                                            path;
                                                      });
                  },
                  child: Text(projectPath == null? "Select Path" : "Path: $projectPath"),
                )
              ),
            ),
            SizedBox(
              height: getProportionateScreenHeight(20),
            ),
            if(projectName != null && projectPath != null && Directory(projectPath!).existsSync())
            TyphonButtonWidget(
              onPressed: () async {
                if (projectName == null || projectPath == null) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("Please fill in all fields"),
                  ));
                  return;
                }
                
                var result = await ProjectInitializationService.createProject(type: widget.type, name: projectName!, location: projectPath!);

                result.fold((l) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(l),
                  ));
                }, (r) {
                });
              },
              child: Text("Create Project"),
            ),
          ],
        ),
      ),
    );
  }
}
