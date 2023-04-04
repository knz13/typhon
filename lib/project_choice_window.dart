




import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:typhon/general_widgets.dart';


void CreateNewProject(String path) {

}

class ProjectChoiceWindow extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    

    return SafeArea(
      child: Scaffold(
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width*0.2,
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(builder:(context) {
                      return ProjectCreationWindow();
                    },));
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GeneralText("New Project"),
                      SizedBox(
                        width: MediaQuery.of(context).size.width*0.05,
                      ),
                      const Icon(Icons.check),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      )
    );
  }

}


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



