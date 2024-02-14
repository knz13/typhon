


import 'package:dartz/dartz.dart' show Either,Left,Right;
import 'package:flutter/material.dart';
import 'package:typhon/config/size_config.dart';
import 'package:typhon/features/global_widgets/typhon_button_widget.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key,required this.futureFunction});


  final Future<Either<String,String>> Function() futureFunction;

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: widget.futureFunction(),
        builder: (context, snapshot) {

          if(!snapshot.hasData){
            return const CircularProgressIndicator();
          }

          if(snapshot.data is Left){
            return Column(children: [
              Text((snapshot.data as Left).value,style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold)),
              SizedBox(
                height: getProportionateScreenHeight(20),
              ),
              TyphonButtonWidget(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("Go Back",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold)),
              )
            ]);
          }

          return Column(children: [
            const CircularProgressIndicator()
          ]);
        },
      ),
    );
  }
}