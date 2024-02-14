import 'package:flutter/material.dart';
import 'package:typhon/config/theme.dart';
import 'package:typhon/features/project_initialization/data/project_model.dart';

import '../../../utils/utils.dart';

class ProjectOverviewWidget extends StatefulWidget {
  const ProjectOverviewWidget({super.key, required this.project});

  final ProjectModel project;

  @override
  State<ProjectOverviewWidget> createState() => _ProjectOverviewWidgetState();
}

class _ProjectOverviewWidgetState extends State<ProjectOverviewWidget> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (event) {
        setState(() {
          isHovered = true;
        });
      },
      onExit: (event) {
        setState(() {
          isHovered = false;
        });
      },
      child: Card(
          surfaceTintColor: Colors.transparent,
          color: isHovered ? ConfigColors.searchColor : ConfigColors.jetBlack,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Text(
                      widget.project.name,
                      style: TextStyle(
                          color: isHovered
                              ? ConfigColors.platinumGray
                              : ConfigColors.platinumGray),
                    ),
                    Text(
                      widget.project.location,
                      style: TextStyle(
                          color: isHovered
                              ? ConfigColors.platinumGray
                              : ConfigColors.platinumGray),
                    ),
                  ],
                ),
                Text(
                  Utils.formatDate(widget.project.lastModified),
                  style: TextStyle(
                      color: isHovered
                          ? ConfigColors.platinumGray
                          : ConfigColors.platinumGray),
                ),
              ],
            ),
          )),
    );
  }
}
