import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Utils.dart';

class BottomBarItemComponent extends StatelessWidget{
  void clickItemBar(int value){
    BuildContext globalContext = Utils.navigatorKey.currentContext!;
    Utils.selectIndex = value;
    print("select index= ${Utils.selectIndex}");
    if(value == 0){
      Navigator.pushNamed(globalContext, '/home');
    }
    if(value == 1){
      Navigator.pushNamed(globalContext, '/product');

    }
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return BottomNavigationBar(
        onTap: (value) {
          return clickItemBar(value);
        },
        currentIndex: Utils.selectIndex,
        selectedItemColor: Colors.orange,
        backgroundColor: Colors.green,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home),label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.add_card),label: "Product"),
          BottomNavigationBarItem(icon: Icon(Icons.chat),label: "Chat"),
        ]);
  }

}