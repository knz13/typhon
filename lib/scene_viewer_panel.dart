





import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:typhon/engine_sub_window.dart';

import 'engine.dart';

class SceneViewerPanel extends StatelessWidget {

  Widget build(BuildContext context) {
    return Column(
      children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height*0.04,
            color: EngineSubWindow.tabColor,
          ),
          Expanded(
            child: GameWidget(game: Engine(),)
          )
      ],
    );
  }

}