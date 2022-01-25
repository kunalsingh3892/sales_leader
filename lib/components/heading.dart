import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Heading extends StatelessWidget {
  final String title;
  Heading({this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[

        SizedBox(
          width: 15.0,
        ),
        Expanded(
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600,
              fontSize: 18.0,
            ),
          ),
        )
      ],
    );
  }
}