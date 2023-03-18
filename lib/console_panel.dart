




import 'package:flutter/material.dart' hide MenuBar hide MenuStyle;

class ConsolePanel extends StatefulWidget {


  void show(String message) {
    _addString.value = message;
  }

  ValueNotifier<String?> _addString = ValueNotifier(null);

  @override
  State<ConsolePanel> createState() => _ConsolePanelState();
}

class _ConsolePanelState extends State<ConsolePanel> {

  List<String> data = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    widget._addString.addListener(() {
      if(widget._addString.value != null) {
        setState(() {
          data.add(widget._addString.value!);
        });
        widget._addString.value = null;
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container();
  }
}