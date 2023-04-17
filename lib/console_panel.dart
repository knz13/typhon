





import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide MenuBar hide MenuStyle;
import 'package:typhon/engine_sub_window.dart';
import 'package:typhon/general_widgets.dart';

enum ConsolePanelLevel {
  warning,
  error,
  log
}

class ConsolePanelMessage {
  Widget? leading;
  String text;

  ConsolePanelMessage({required this.text,this.leading});
}

class ConsolePanelLeadingWidget extends StatefulWidget {


  ConsolePanelLeadingWidget({super.key,required this.notifier});

  ValueNotifier<Widget?> notifier;

  @override
  State<ConsolePanelLeadingWidget> createState() => _ConsolePanelLeadingWidgetState();
}

class _ConsolePanelLeadingWidgetState extends State<ConsolePanelLeadingWidget> {


  void onNotifierChange() {
    setState(() {
    });
  }

  @override
  void initState() {
    super.initState();

    widget.notifier.addListener(onNotifierChange);
  }

  @override
  void dispose() {
    super.dispose();

    widget.notifier.removeListener(onNotifierChange);
  }

  @override
  Widget build(BuildContext context) {
    return widget.notifier.value ?? SizedBox();
  }
}

class ConsolePanelSubWindow extends EngineSubWindowData {

  static ValueNotifier<Widget?> leadingWidgetNotifier = ValueNotifier(null);

  ConsolePanelSubWindow() : super(child: ConsolePanel(), title: 'Console',tabLeading: (context, status) {
      return ConsolePanelLeadingWidget(notifier: leadingWidgetNotifier);
  },onTabSelected: () {
    leadingWidgetNotifier.value = null;
  }) {
    ConsolePanel.leadingWidget = leadingWidgetNotifier;
  }


  
}

class ConsolePanel extends StatefulWidget {


  static void clear() {
    _data.clear();
    leadingWidget.value = null;
    onMessagesChange.value++;
  }

  static void show(String message,{ConsolePanelLevel level = ConsolePanelLevel.log}) {
    if(kDebugMode){
      print(message);
    }
    ConsolePanel._data.addFirst(ConsolePanelMessage(text: message,leading: level == ConsolePanelLevel.log ? Icon(Icons.message) : level == ConsolePanelLevel.warning ? Icon(Icons.warning) : Icon(Icons.error)));
    if(ConsolePanel._data.length > ConsolePanel.maxMessages) {
      ConsolePanel._data.removeLast();
    }

    if(level == ConsolePanelLevel.error){
      leadingWidget.value = Icon(Icons.error);
    }
    onMessagesChange.value++;
  }


  static int maxMessages = 100;
  static ValueNotifier<Widget?> leadingWidget = ValueNotifier(null);
  static Queue<ConsolePanelMessage> _data = Queue();
  static ValueNotifier<int> onMessagesChange = ValueNotifier(0);

  @override
  State<ConsolePanel> createState() => _ConsolePanelState();
}

class _ConsolePanelState extends State<ConsolePanel> {


  void onChange() {
    setState(() {
        
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    ConsolePanel.onMessagesChange.addListener(onChange);

  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    ConsolePanel.onMessagesChange.removeListener(onChange);

  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ListView.builder(
      
      itemBuilder:(context, index) {
      return ListTile(
        leading: ConsolePanel._data.elementAt(index).leading,
        title: GeneralText(ConsolePanel._data.elementAt(index).text,overflow: TextOverflow.visible,),
      );
    },itemCount: ConsolePanel._data.length,);
  }
}