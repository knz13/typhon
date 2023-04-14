





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
  bool moveFreely = false;

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
            if(!moveFreely){
              controller.animateTo(
                  controller.position.maxScrollExtent,
                  curve: Curves.easeOut,
                  duration: const Duration(milliseconds: 1),
              );
            }
          });
        });
        

        widget.notifier.value!.stderr.listen((event) {
          setState(() {
            currentMessage.addLast(RecompilingMessage(message: String.fromCharCodes(event),type: "ERROR"));
            if(!moveFreely){
              controller.animateTo(
                  controller.position.maxScrollExtent,
                  curve: Curves.easeOut,
                  duration: const Duration(milliseconds: 1),
              );
            }
          });
        });
        

      }
    });
  }

  Widget dialogBodyContent(String title){
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                flex:1,
                child: SizedBox(),
              ),
              Expanded(
                flex:9,
                child: GeneralText(title,alignment: TextAlign.center,)
              ),
              Expanded(
                flex: 1,
                child: GeneralButton(
                  onPressed: () {
                    setState(() {
                      moveFreely = !moveFreely;
                    });
                  },
                  child: moveFreely? Icon(Icons.lock_open_outlined) : Icon(Icons.lock_outline),
                ),
              )
            ],
          ),
        ),
        Row(
          children: [
            Expanded(
              child: Container(
                color: primaryBlack,
                height: 2,
              ),
            ),
          ],
        ),
        Expanded(
          child: ListView.builder(
            physics: moveFreely? null : const NeverScrollableScrollPhysics(),
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
        height: 400,
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