import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uber_clone/screens/auth/intro.dart';
import 'package:uber_clone/screens/auth/login.dart';
import 'package:uber_clone/ui_reuse/widgets/constants.dart';
import 'package:uber_clone/ui_reuse/widgets/divider.dart';

class DrawerContainer extends StatelessWidget {


  const DrawerContainer({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: 255,
      child: Drawer(
        child: ListView(
          children: [
            Container(
              height: 165,
              child: DrawerHeader(
                decoration: BoxDecoration(color: Colors.white),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/images/user_icon.png',
                      height: 65.0,
                    ),
                    SizedBox(
                      width: 16.0,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          uName,
                          style: TextStyle(
                              fontSize: 16.0, fontFamily: 'Semibold'),
                        ),
                        SizedBox(
                          height: 6,
                        ),
                        Text('Visit Profile'),
                      ],
                    )
                  ],
                ),
              ),
            ),
            DividerWidget(),
            SizedBox(
              height: 12.0,
            ),
            ListTile(
              leading: Icon(Icons.history),
              title: Text(
                'History',
                style: TextStyle(fontSize: 16.0),
              ),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text(
                'Visit Profile',
                style: TextStyle(fontSize: 16.0),
              ),
            ),
            ListTile(
              leading: Icon(Icons.info),
              title: Text(
                'About',
                style: TextStyle(fontSize: 16.0),
              ),
            ),
            GestureDetector(
              onTap: (){
                FirebaseAuth.instance.signOut();
                Navigator.pushNamedAndRemoveUntil(context, WelcomePage.routeName, (route) => false);
              },
              child: ListTile(
                leading: Icon(Icons.info),
                title: Text(
                  'Sign Out',
                  style: TextStyle(fontSize: 16.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
