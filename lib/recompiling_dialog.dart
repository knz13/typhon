





import 'dart:collection';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';

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
    
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          backgroundColor: Colors.blue,
          child: Column(
            children: [
              GeneralText("Recompiling..."),
              Expanded(
                child: ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
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
          ),
        )
    );
  }
}