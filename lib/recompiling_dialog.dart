





import 'dart:collection';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:typhon/main.dart';

import 'general_widgets.dart';

class RecompilingDialog extends StatefulWidget {

  RecompilingDialog({required this.notifier});

  ValueNotifier<Process?> notifier;

  @override
  State<RecompilingDialog> createState() => _RecompilingDialogState();
}

class RecompilingMessage {
  String message;
  String type;

  RecompilingMessage({this.message ="",this.type = ""});
}

class _RecompilingDialogState extends State<RecompilingDialog> {
  ScrollController controller = ScrollController();
  Queue<RecompilingMessage> currentMessage = Queue();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    widget.notifier.addListener(() {
      if(widget.notifier.value != null){
        setState(() {
          currentMessage.clear();
        });

        widget.notifier.value!.stdout.listen((event) {
          setState(() {
            currentMessage.addLast(RecompilingMessage(message: String.fromCharCodes(event),type: "LOG"));
            controller.animateTo(
                controller.position.maxScrollExtent,
                curve: Curves.easeOut,
                duration: const Duration(milliseconds: 1),
            );
          });
        });
        

        widget.notifier.value!.stderr.listen((event) {
          setState(() {
            currentMessage.addLast(RecompilingMessage(message: String.fromCharCodes(event),type: "ERROR"));
            controller.animateTo(
                controller.position.maxScrollExtent,
                curve: Curves.easeOut,
                duration: const Duration(milliseconds: 1),
            );
          });
        });
        

      }
    });
  }

  Widget dialogBodyContent(String title){
    return Column(
      children: [
        GeneralText(title),
        Expanded(
          child: ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            controller: controller,
            itemBuilder:(context, index) {
              return ListTile(
                title: GeneralText(currentMessage.elementAt(index).message,color: currentMessage.elementAt(index).type == "LOG"? platinumGray : Colors.red,overflow: TextOverflow.visible,),
              );
            },
            itemCount: currentMessage.length,
          ),
        )
      ],
    );
  }


  @override
  Widget build(BuildContext context){
    return Dialog(
      child: Container(
        width: 375,
        height: 200,
        decoration: BoxDecoration(
          color: activeColor.withOpacity(0.5),
          borderRadius: BorderRadius.circular(3),
          boxShadow: [
            BoxShadow(
              color: activeColor,
              blurRadius: 1,
            ),
            const BoxShadow(
              color: Colors.black38,
              offset: Offset(0, 10),
              blurRadius: 10,
            )
          ],
        ),
        child: dialogBodyContent("Recompiling..."),
      ),
    );
  }
}