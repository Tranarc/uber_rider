import 'package:flutter/material.dart';

class DrawerPositionedWidget extends StatelessWidget {
  final IconData iconData;
  final Function() press;
  const DrawerPositionedWidget({
    Key? key,
    required this.iconData,
    required this.press
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 40.0,
      left: 22.0,
      child: GestureDetector(
        onTap: press,
        child: Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black,
                  blurRadius: 6.0,
                  spreadRadius: 0.5,
                  offset: Offset(0.7, 0.7),
                )
              ]),
          child: CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(
              iconData,
              color: Colors.black,
            ),
            radius: 20.0,
          ),
        ),
      ),
    );
  }
}
