import 'package:quanlidoanvien/Components/AppBarComponent.dart';
import 'package:flutter/material.dart';

import '../../Components/BottomBarItemComponent.dart';
import '../../Models/ProductModel.dart';
import '../../Utils.dart';

class ProductView extends StatelessWidget{
  List<ProductModel> productList = [];
  ProductView(){

  }
  void clickItem(int value){
    BuildContext globalContext = Utils.navigatorKey.currentContext!;
    Navigator.pushNamed(globalContext, '/productDetail',arguments: {"id": value});
  }
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    // TODO: implement build
    return Scaffold(
      appBar: AppBarComponent("Product"),
      body: ListView.builder(

          itemCount: productList.length, // Specify the total number of items
          itemBuilder: (BuildContext context, int index) {
            // Build and return the widget for each item
            return Card(
              margin: EdgeInsets.all(8.0),
              child: Container(
                  
                child: GestureDetector(
                  onTap: () {
                    return clickItem(productList[index].id);
                  },
                    child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.all(5),
                      width: width * 0.3,
                      height: width * 0.3,
                      decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage("${productList[index].imageUrl}"), // Path to your image
                            fit: BoxFit.cover, // Adjust how the image covers the container
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          border: Border.all(color: Colors.black54,width: 1)
                      ),
                    ),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${productList[index].name}",style: TextStyle(color: Colors.red,fontSize: 25),),
                        Text("${productList[index].price}"),
                      ],
                    ))

                  ],
                )) ,
              ),
            );
          }),
      bottomNavigationBar: BottomBarItemComponent(),
    );;
  }

}