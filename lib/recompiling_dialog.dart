// ignore_for_file: prefer_const_constructors

import 'dart:collection';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:typhon/config/theme.dart';
import 'package:typhon/console_panel.dart';
import 'package:typhon/main.dart';

import 'widgets/general_widgets.dart';

class RecompilingDialog extends StatefulWidget {
  RecompilingDialog({required this.process, this.onLeaveRequest});

  Process process;
  void Function()? onLeaveRequest;

  @override
  State<RecompilingDialog> createState() => _RecompilingDialogState();
}

class RecompilingMessage {
  String message;
  String type;

  RecompilingMessage({this.message = "", this.type = ""});
}

class _RecompilingDialogState extends State<RecompilingDialog> {
  ScrollController controller = ScrollController();
  Queue<RecompilingMessage> currentMessage = Queue();
  bool moveFreely = false;

  void stdOutEvent(event) {
    if (mounted) {
      setState(() {
        currentMessage.addLast(RecompilingMessage(
            message: String.fromCharCodes(event), type: "LOG"));
        if (!moveFreely) {
          controller.animateTo(
            controller.position.maxScrollExtent,
            curve: Curves.easeOut,
            duration: const Duration(milliseconds: 1),
          );
        }
      });
    }
  }

  void stdErrEvent(event) {
    if (mounted) {
      setState(() {
        currentMessage.addLast(RecompilingMessage(
            message: String.fromCharCodes(event), type: "ERROR"));
        if (!moveFreely) {
          controller.animateTo(
            controller.position.maxScrollExtent,
            curve: Curves.easeOut,
            duration: const Duration(milliseconds: 1),
          );
        }
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    widget.process.stdout.listen(stdOutEvent);

    widget.process.exitCode.then((value) {
      if (value != 0) {
        String value = "";
        for (int i in List.generate(
            currentMessage.length > 30 ? 30 : currentMessage.length,
            (index) => currentMessage.length - index - 1)) {
          value += currentMessage.elementAt(i).message;
        }
        if (value != "") {
          ConsolePanel.show(value, level: ConsolePanelLevel.error);
        }
      }
    });

    widget.process.stderr.listen(stdErrEvent);
  }

  @override
  void dispose() {
    // TODO: implement dispose

    super.dispose();
  }

  Widget dialogBodyContent(String title) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: GeneralButton(
                  onPressed: widget.onLeaveRequest ?? () {},
                  child: Icon(Icons.close),
                ),
              ),
              Expanded(
                  flex: 9,
                  child: GeneralText(
                    title,
                    alignment: TextAlign.center,
                  )),
              Expanded(
                flex: 1,
                child: GeneralButton(
                  onPressed: () {
                    setState(() {
                      moveFreely = !moveFreely;
                    });
                  },
                  child: moveFreely
                      ? Icon(Icons.lock_open_outlined)
                      : Icon(Icons.lock_outline),
                ),
              )
            ],
          ),
        ),
        Row(
          children: [
            Expanded(
              child: Container(
                color: ConfigColors.primaryBlack,
                height: 2,
              ),
            ),
          ],
        ),
        Expanded(
          child: ListView.builder(
            physics: moveFreely ? null : const NeverScrollableScrollPhysics(),
            controller: controller,
            itemBuilder: (context, index) {
              return ListTile(
                title: GeneralText(
                  currentMessage.elementAt(index).message,
                  color: currentMessage.elementAt(index).type == "LOG"
                      ? platinumGray
                      : Colors.red,
                  overflow: TextOverflow.visible,
                ),
              );
            },
            itemCount: currentMessage.length,
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 375,
        height: 400,
        decoration: BoxDecoration(
          color: ConfigColors.activeColor.withOpacity(0.5),
          borderRadius: BorderRadius.circular(3),
          boxShadow: [
            BoxShadow(
              color: ConfigColors.activeColor,
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
