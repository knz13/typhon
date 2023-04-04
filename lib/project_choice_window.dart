import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:typhon/general_widgets.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class Tile {
  int idx = 0;
  String title = "All templates";
  Widget leading = const Icon(Icons.menu,color: Colors.white70);
}

class MiddleTile {
  int idx = 0;
  String title = "3D";
  String subtitle = "Core";
  Widget leading = Transform.rotate(
    angle: 155,
    child: Icon(
      MdiIcons.cube,
      color: Colors.white.withOpacity(0.8),
      size: 42,
    ),
  );
}

class ProjectChoiceWindow extends StatefulWidget {
  const ProjectChoiceWindow({Key? key}) : super(key: key);

  @override
  State<ProjectChoiceWindow> createState() => _ProjectChoiceWindowState();
}

class _ProjectChoiceWindowState extends State<ProjectChoiceWindow> {
  // Controllers
  int selectedMiddleOptionMenu = 0;
  int selectedOptionSideMenu = 0;

  // Colors
  Color leadingIconColor = Colors.white.withOpacity(0.8);
  Color activeColor = const Color.fromRGBO(62,62,62,1);
  Color dividerColor = Colors.black26;
  Color searchColor = const Color.fromRGBO(159, 159, 159  , 1);

  Container tileLeftMenu(Tile tile){
    return Container(
      height: 50,
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
          title: Text(tile.title,style: const TextStyle(color: Colors.white,fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }

  Container middleTileMenu(MiddleTile middleTile){
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: const Color.fromRGBO(36, 36, 36, 1),
        borderRadius: BorderRadius.circular(5),
        border: selectedMiddleOptionMenu == middleTile.idx? Border.all(width: 3,color: Colors.blue) : Border.all(width: 3,color: Colors.transparent)
      ),
      child: RawMaterialButton(
        onPressed: (){
          setState(() {
            selectedMiddleOptionMenu = selectedMiddleOptionMenu == middleTile.idx? -1 : middleTile.idx;
          });
        },
        child: Center(
          child: ListTile(
            leading: middleTile.leading,
            title: Text(middleTile.title,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 20
                )
            ),
            subtitle: Text(middleTile.subtitle,
              style: const TextStyle(
                  fontSize: 16,
                  letterSpacing: 0,
                  color: Colors.white54
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Tile> listOfTiles = [
      Tile()
        ..idx = 0
        ..title = "All templates"
        ..leading = Icon(Icons.menu,color: leadingIconColor),
      Tile()
        ..idx = 1
        ..title = "New"
        ..leading = Icon(MdiIcons.star,color: leadingIconColor),
      Tile()
        ..idx = 2
        ..title = "Core"
        ..leading = Icon(MdiIcons.focusField,color: leadingIconColor),
      Tile()
        ..idx = 3
        ..title = "Sample"
        ..leading = Icon(MdiIcons.selectGroup,color: leadingIconColor),
      Tile()
        ..idx = 4
        ..title = "Learning"
        ..leading = Icon(Icons.school,color: leadingIconColor),
    ];

    List<MiddleTile> middleTileList = [
      MiddleTile()
        ..idx = 0
        ..title = "2D"
        ..subtitle = "Core"
        ..leading = Transform.rotate(
          angle: 155,
          child: Icon(
            MdiIcons.cubeOutline,
            color: Colors.white.withOpacity(0.8),
            size: 42,
          ),
        ),

      MiddleTile()
        ..idx = 1
        ..title = "3D"
        ..subtitle = "Core"
        ..leading = Transform.rotate(
          angle: 155,
          child: Icon(
            MdiIcons.cube,
            color: Colors.white.withOpacity(0.8),
            size: 42,
          ),
        ),
    ];

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          centerTitle: true,
          title: const Text("New Project",style: TextStyle(color: Colors.white,fontWeight: FontWeight.w700)),
          backgroundColor: Colors.black,
        ),
        body: Column(
          children: [
            Divider(
              height: 0.5,
              color: dividerColor,
            ),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Container(
                      height: MediaQuery.of(context).size.height,
                      color: const Color.fromRGBO(36,36,36,1),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              for(Tile tile in listOfTiles)
                                Padding(
                                  padding: const EdgeInsets.only(top: 7.5),
                                  child: tileLeftMenu(tile),
                                ),
                            ],
                          ),
                        ),
                      )
                    )
                  ),
                  VerticalDivider(
                    width: 0.5,
                    color: dividerColor,
                  ),
                  Expanded(
                    flex: 5,
                    child: Container(
                      height: MediaQuery.of(context).size.height,
                      color: const Color.fromRGBO(20,20,20,1),
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 22.5),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 7.5),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    border: Border.all(
                                      color: Colors.white10,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(5)
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 15),
                                    child: TextFormField(
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600
                                      ),
                                      decoration: InputDecoration(
                                        icon: Icon(Icons.search,color: searchColor),
                                        hintText: "Search all templates",
                                        hoverColor: Colors.white,
                                        hintStyle: TextStyle(
                                          color: searchColor
                                        ),
                                        border: InputBorder.none,
                                      ),
                                      cursorColor: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              for(MiddleTile middleTile in middleTileList)
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 6),
                                  child: middleTileMenu(middleTile),
                                )
                            ]
                          ),
                        ),
                      ),
                    )
                  ),
                  VerticalDivider(
                    width: 0.5,
                    color: dividerColor,
                  ),
                  Expanded(
                    flex: 4,
                    child: SingleChildScrollView(
                      child: Column(

                      )
                    )
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}





// class ProjectChoiceWindow extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         body: Container(
//           width: MediaQuery.of(context).size.width,
//           height: MediaQuery.of(context).size.height,
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               SizedBox(
//                 width: MediaQuery.of(context).size.width*0.2,
//                 child: InkWell(
//                   onTap: () {
//                     Navigator.of(context).push(MaterialPageRoute(builder:(context) {
//                       return ProjectCreationWindow();
//                     },));
//                   },
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       GeneralText("New Project"),
//                       SizedBox(
//                         width: MediaQuery.of(context).size.width*0.05,
//                       ),
//                       const Icon(Icons.check),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       )
//     );
//   }
//
// }
//

class ProjectCreationWindow extends StatelessWidget { 
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
              flex: 8,
              child: Column(
                children: [
                  InkWell(
                    onTap: () {
                      
                    },
                    child: GeneralText("Project Directory"),
                  )
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                color: Colors.blue,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      customBorder: const RoundedRectangleBorder(side: BorderSide(color: Colors.black)),
                      child: GeneralText("Cancel"),
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width*0.1,),
                    InkWell(
                      customBorder: const RoundedRectangleBorder(side: BorderSide(color: Colors.black)),
                      child: GeneralText("Create"),
                    )
                  ],
                ),
              )
            )
          ],
        ),
      )
    );
  }
}