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
      body: Column(
        children: [
          Text("Project Name",
              style: TextStyle(
                  color: ConfigColors.platinumGray,
                  fontSize: getProportionateScreenWidth(20))),
          SizedBox(
            height: getProportionateScreenHeight(10),
          ),
          CustomizedTextField(onChanged: (v) {
            setState(() {
              projectName = v;
            });
          }),
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
          CustomizedTextField(onChanged: (v) {
            setState(() {
              projectPath = v;
            });
          }),
        ],
      ),
    );
  }
}
