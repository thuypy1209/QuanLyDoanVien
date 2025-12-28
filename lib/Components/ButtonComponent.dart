import 'package:flutter/material.dart';

class ButtonComponent extends StatelessWidget{
  late double width;
  late double height;
  late String textValue;

  ButtonComponent(this.width, this.height, this.textValue);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      width: this.width,
      height: this.height,
      color: Colors.blue,
      child: Center(
        child: Text(
          this.textValue,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

}