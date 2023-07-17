



import 'package:flutter/material.dart' hide MenuBar hide MenuStyle;
import 'package:typhon/engine.dart';
import 'package:typhon/typhon_bindings.dart';

import '../engine_sub_window.dart';

class InspectorPanelData {

  InspectorPanelData({this.dataToShow = const [],this.objectID,this.topPanelData});

  List<Widget> dataToShow;
  Widget? topPanelData;
  int? objectID;
}

class InspectorPanelWindow extends EngineSubWindowData {

  static ValueNotifier<InspectorPanelData> data = ValueNotifier(InspectorPanelData());

  InspectorPanelWindow() : super(child: InspectorPanel(),topPanelWidgets: InspectorPanelTopWidget(), title: "Inspector",onTabSelected: () {
    
  });

}

class InspectorPanelTopWidget extends StatefulWidget {
  @override
  State<InspectorPanelTopWidget> createState() => _InspectorPanelTopWidgetState();
}

class _InspectorPanelTopWidgetState extends State<InspectorPanelTopWidget> {

  void callbackToDataChanged() {
    setState(() {
      
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    InspectorPanelWindow.data.addListener(callbackToDataChanged);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    InspectorPanelWindow.data.removeListener(callbackToDataChanged);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return InspectorPanelWindow.data.value.topPanelData ?? Container();
  }
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

  void onChildrenChangedCallback() {
    if(mounted && !Engine.instance.currentChildren.value.contains(InspectorPanelWindow.data.value.objectID)){
      InspectorPanelWindow.data.value = InspectorPanelData();
      
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    Engine.instance.currentChildren.addListener(onChildrenChangedCallback);
    InspectorPanelWindow.data.addListener(onSelectedChanged);
    super.initState();

  }

  @override
  void dispose() {
    // TODO: implement dispose
    Engine.instance.currentChildren.removeListener(onChildrenChangedCallback);
    InspectorPanelWindow.data.removeListener(onSelectedChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: InspectorPanelWindow.data.value.dataToShow,
      ),
    );
  }
}