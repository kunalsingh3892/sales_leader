import 'package:flutter/material.dart';

import '../constants.dart';

class ProfileImage extends StatelessWidget {
  final double height, width;
  final Color color;
  ProfileImage(
      {this.height = 80.0, this.width = 80.0, this.color = primaryColor});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xfffb4d6d),
        image: DecorationImage(
          image: AssetImage('assets/images/glen_logo.png'),
          fit: BoxFit.contain,
        ),
        border: Border.all(
          color: color,
          width: 3.0,
        ),
      ),
    );
  }
}