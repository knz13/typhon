import 'package:flame/game.dart';
import 'package:flutter/material.dart' hide MenuBar hide MenuStyle;
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:typhon/console_panel.dart';
import 'package:typhon/engine_sub_window.dart';
import 'package:typhon/general_widgets.dart';
import 'package:typhon/hierarchy_panel.dart';
import 'package:typhon/inspector_panel.dart';
import 'package:typhon/project_choice_window.dart';
import 'package:typhon/scene_viewer_panel.dart';
import 'engine.dart';
import 'file_viewer_panel.dart';
import 'main_engine_frontend.dart';
import 'package:window_size/window_size.dart';
import 'dart:io';

Color activeColor = const Color.fromRGBO(62,62,62,1);
Color blueColor = const Color.fromRGBO(63,117,195,1);
Color primaryBlack = const Color.fromRGBO(20,20,20,1);
Color secondaryBlack = const Color.fromRGBO(36,36,36,1);

class Tile {
  int idx = 0;
  String title = "Projects";
  Widget leading = const Icon(Icons.menu,color: Colors.white70);
}

double contextWidth(var context){
  return MediaQuery.of(context).size.width;
}
double contextHeight(var context){
  return MediaQuery.of(context).size.height;
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowTitle('Typhon');
    setWindowMinSize(const Size(1280, 600));
    setWindowMaxSize(Size.infinite);
  }
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {

    super.initState();
    initializeContextMenu();

  }
  int page = 1;
  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      title: 'Typhon',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Stack(
          children: [
            [
              MainEngineFrontend(),
              const ProjectsPage(),
              const ProjectChoiceWindow(),
            ][page%3],

            Positioned(
              top: 0,
              right: 0,
              child: Container(
                height: 50,
                width: 50,
                color: Colors.black,
                child: RawMaterialButton(
                  onPressed: (){
                    setState(() {
                      page++;
                      page %= 3;
                    });
                  },
                  child: const Icon(MdiIcons.reload,color: Colors.white,),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class ProjectsPage extends StatefulWidget {
  const ProjectsPage({Key? key}) : super(key: key);

  @override
  State<ProjectsPage> createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> {
  int selectedOptionSideMenu = 0;

  Container tileLeftMenu(Tile tile){
    return Container(
      height: 60,
      decoration: BoxDecoration(
          color: selectedOptionSideMenu == tile.idx? activeColor: Colors.transparent,
          borderRadius: BorderRadius.circular(5)
      ),
      child: Center(
        child: ListTile(
          onTap: (){
            setState(() {
              selectedOptionSideMenu = tile.idx;
            });
          },
          leading: tile.leading,
          title: Text(tile.title,style: const TextStyle(color: Colors.white,fontWeight: FontWeight.w600,fontSize: 20)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            child: Container(
              color: secondaryBlack,
              child: Column(
                children: [
                  RawMaterialButton(
                    onPressed: (){},
                    child: Container(
                      height: 175,
                      color: secondaryBlack
                    ),
                  ),
                  const Divider(
                    height: 2,
                    color: Colors.grey,
                  ),
                  Expanded(
                    flex: 8,
                    child: Container(
                      color: secondaryBlack,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 20),
                        child: Column(
                          children: [
                            tileLeftMenu(
                              Tile()
                              ..leading = Transform.rotate(
                                angle: 155,
                                child: Icon(
                                  MdiIcons.cube,
                                  color: Colors.white.withOpacity(0.8),
                                  size: 30,
                                ),
                              )
                              ..title = "Projects"
                              ..idx = 0
                            ),
                            tileLeftMenu(
                              Tile()
                              ..leading = Transform.rotate(
                                angle: 0,
                                child: Icon(
                                  MdiIcons.sackPercent,
                                  color: Colors.white.withOpacity(0.8),
                                  size: 30,
                                ),
                              )
                              ..title = "Installs"
                              ..idx = 1
                            ),

                            tileLeftMenu(
                              Tile()
                              ..leading = Transform.rotate(
                                angle: 0,
                                child: Icon(
                                  MdiIcons.schoolOutline,
                                  color: Colors.white.withOpacity(0.8),
                                  size: 30,
                                ),
                              )
                              ..title = "Learn"
                              ..idx = 2
                            ),

                            tileLeftMenu(
                              Tile()
                              ..leading = Transform.rotate(
                                angle: 0,
                                child: Icon(
                                  Icons.group,
                                  color: Colors.white.withOpacity(0.8),
                                  size: 30,
                                ),
                              )
                              ..title = "Community"
                              ..idx = 3
                            ),
                          ],
                        ),
                      ),
                    )
                  ),
                  const Divider(
                    height: 2,
                    color: Colors.grey,
                  ),
                  Expanded(
                    child: Container(
                      color: secondaryBlack,
                      child: RawMaterialButton(
                        onPressed: (){},
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 25),
                              child: Icon(Icons.download,color: Colors.white.withOpacity(0.8),size: 32),
                            ),
                            const Text("Downloads",style: TextStyle(color: Colors.white,fontSize: 18),)
                          ],
                        )
                      ),
                    )
                  ),
                ],
              ),
            ),
          ),
          const VerticalDivider(
            width: 1,
            color: Colors.grey,
          ),

          Expanded(
            flex: 3,
            child: Container(
              color: primaryBlack,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 27.5,vertical: 15),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Projects",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w400,
                                fontSize: 48
                              ),
                            ),

                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      height: 40,
                                      width: 80,
                                      decoration: BoxDecoration(
                                          color: activeColor,
                                          borderRadius: const BorderRadius.horizontal(left: Radius.circular(3))
                                      ),
                                      child: RawMaterialButton(
                                        onPressed: (){},
                                        child: const Text(
                                          "Open",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 18
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 2,
                                    ),
                                    Container(
                                      height: 40,
                                      width: 40,
                                      decoration: BoxDecoration(
                                          color: activeColor,
                                          borderRadius: const BorderRadius.horizontal(right: Radius.circular(3))
                                      ),
                                      child: RawMaterialButton(
                                        onPressed: (){},
                                        child: const Icon(Icons.arrow_drop_down_rounded,color: Colors.white,size: 26,)
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Container(
                                  height: 40,
                                  width: 120,
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(5)
                                  ),
                                  child: RawMaterialButton(
                                    onPressed: (){},
                                    child: const Text(
                                      "New Project",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
