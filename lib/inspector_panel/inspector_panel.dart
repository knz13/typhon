



import 'package:flutter/material.dart' hide MenuBar hide MenuStyle;
import 'package:typhon/typhon_bindings.dart';

import '../engine_sub_window.dart';


class InspectorPanelWindow extends EngineSubWindowData {

  static ValueNotifier<List<Widget>> dataToShow = ValueNotifier([Container()]);

  InspectorPanelWindow() : super(child: InspectorPanel(), title: "Inspector",onTabSelected: () {
    
  });

}

class InspectorPanel extends StatefulWidget {

  

  @override
  State<InspectorPanel> createState() => _InspectorPanelState();
}

class _InspectorPanelState extends State<InspectorPanel> {


  void onSelectedChanged() {
      setState(() {
        
      });
  }

  @override
  void initState() {
    // TODO: implement initState
    InspectorPanelWindow.dataToShow.addListener(onSelectedChanged);
    super.initState();

  }

  @override
  void dispose() {
    // TODO: implement dispose
    InspectorPanelWindow.dataToShow.removeListener(onSelectedChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Column(
      children: InspectorPanelWindow.dataToShow.value,
    );
  }
}