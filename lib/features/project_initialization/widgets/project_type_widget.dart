import 'package:flutter/material.dart';
import 'package:typhon/config/theme.dart';

import '../../../utils/utils.dart';
import '../data/project_type.dart';

class ProjectTypeWidget extends StatefulWidget {
  const ProjectTypeWidget({super.key, required this.project});

  final ProjectType project;

  @override
  State<ProjectTypeWidget> createState() => _ProjectTypeWidgetState();
}

class _ProjectTypeWidgetState extends State<ProjectTypeWidget> {
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
                widget.project.description,
                style: TextStyle(
                    color: isHovered
                        ? ConfigColors.platinumGray
                        : ConfigColors.platinumGray),
              ),
                ],
              ),
              
              ],
            ),
          )),
    );
  }
}
