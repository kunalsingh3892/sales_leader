import 'package:flutter/material.dart';

class Category extends StatelessWidget {
  final String image, title;
  Category({this.title, this.image});
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(right: 10.0, bottom: 10.0),
      child: Container(
        height: 140.0,
        width: 130.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
         Image.asset(
              image,
              height: 40.0,
           color: Color(0xff9b56ff),

            )
               ,
            SizedBox(
              height: 15.0,
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.bold,
              ),
            )
          ],
        ),
      ),
    );
  }
}