import 'package:flutter/material.dart';

class MyWidget {
  Widget mywidget(String text) {
    return Center(
      child: Text(
        text,
        style: TextStyle(fontSize: 18),
      ),
      //sized box berdimmman
    );
  }

  Widget defimagewidget(BuildContext context){
    return Image(image: AssetImage('assets/images/mpholder.png'), width: MediaQuery.of(context).size.width*0.5,
      height:MediaQuery.of(context).size.height*0.2,fit: BoxFit.cover,);
  }
  Widget defimagehelpwidget(BuildContext context){
    return Image(image: AssetImage('assets/images/mpholder.png'),);
  }
}
