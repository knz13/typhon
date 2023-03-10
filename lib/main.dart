import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:typhon/engine_sub_window.dart';

import 'engine.dart';


double contextWidth(var context){
  return MediaQuery.of(context).size.width;
}
double contextHeight(var context){
  return MediaQuery.of(context).size.height;
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MainEngineFrontend(),
    );
  }
}

class MainEngineFrontend extends StatefulWidget {
  const MainEngineFrontend({super.key});


  @override
  State<MainEngineFrontend> createState() => _MainEngineFrontendState();
}

class _MainEngineFrontendState extends State<MainEngineFrontend> {


  late final Engine engine;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    engine = Engine();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: EngineSubWindow(
          shouldShowBorder: false,
          mainChildProportion: 0.4,
          mainChild:  GameWidget(game: engine),
          secondChild: EngineSubWindow(
            mainChildProportion: 0.3,
            mainChild: Text("hi"),
            mainChildTitle: "title!",
            secondChild: Text("he!"),
            division: SubWindowDivision.left,
          )
        )
      ),
    );
  }
}
