import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:typhon/general_widgets/general_widgets.dart';
import 'package:typhon/general_widgets/custom_expansion_tile.dart';
import 'package:typhon/general_widgets/general_text_field.dart';
import 'package:typhon/general_widgets/rotating_arrow_button.dart';
import 'package:typhon/general_widgets/spacings.dart';
import 'package:typhon/inspector_panel/inspector_panel_builder.dart';
import 'package:typhon/inspector_panel/vec3_field_builder.dart';

class ComponentWidget extends StatefulWidget {
  ComponentWidget({super.key, required this.componentData});

  Map<String, dynamic> componentData;

  @override
  State<ComponentWidget> createState() => _ComponentWidgetState();
}

class _ComponentWidgetState extends State<ComponentWidget> {
  Widget buildFields() {
    return Column(
      children: [
        for (var e in widget.componentData["fields"])
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
            child: Row(
              children: [
                Expanded(child: GeneralText(e.keys.first), flex: 1),
                HorizontalSpacing(10),
                buildFieldOfType(
                    e[e.keys.first]["type"], e[e.keys.first]["current_value"])
              ],
            ),
          )
      ],
    );
  }

  Expanded buildFieldOfType(String type, dynamic currentValue) {
    switch (type) {
      case "vec3":
        List<double> values = (currentValue as String)
            .split(" ")
            .map((e) => double.parse(e))
            .toList();
        print(values);
        return Expanded(
            flex: 3,
            child: Vec3FieldBuilder(
              values: values,
              onChange: (p0, p1, p2) {
                print("${p0},${p1},${p2}");
              },
            ));
      default:
        return Expanded(
          child: Container(),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return CustomExpansionTile(
        title: GeneralText(widget.componentData["component_name"]),
        children: [buildFields()]);
  }
}
