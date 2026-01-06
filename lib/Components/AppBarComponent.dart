import 'package:flutter/material.dart';

import 'package:quanlidoanvien/Utils.dart';

class AppBarComponent extends StatelessWidget implements PreferredSizeWidget{
  String titleValue;

  AppBarComponent(this.titleValue);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return AppBar(
      backgroundColor: Colors.green,
      title: Text(titleValue, style: TextStyle(color: Colors.white)),
      actions: [
        Text("hello ${Utils.userName}", style: TextStyle(color: Colors.white, fontSize: 20)),
        SizedBox(width: 20,)
      ],
    );
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

}