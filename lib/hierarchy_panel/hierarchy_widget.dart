




import 'package:flutter/material.dart';
import 'package:typhon/config/colors.dart';
import 'package:typhon/general_widgets.dart';
import 'package:typhon/general_widgets/spacings.dart';

class HierarchyWidget extends StatelessWidget {

  const HierarchyWidget(this.componentName,{super.key,this.componentData = const []});

  final String componentName;
  final List<dynamic> componentData;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(blurRadius: 2)
            ],
            color: Config.midGray
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: Row(
              children: [
                GeneralButton(
                  onPressed: (){
                    
                  },
                  child: Icon(Icons.arrow_drop_down,color: Config.platinumGray,)
                ),
                HorizontalSpacing(5),
                GeneralText(componentName),
              ],
            ),
          ),
        ),
        for(Map map in componentData)
        Container()
      ],
    );
  }

}