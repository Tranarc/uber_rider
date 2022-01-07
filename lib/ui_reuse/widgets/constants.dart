import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uber_clone/models/allUsers.dart';

void showErrDialog(String msg,BuildContext context) {
  showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('An err occurred'),
        content: Text(msg),
        actions: [
          FlatButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: Text('OK'))
        ],
      ));
}

String mapKey = 'Google_Map_Key';

Users? riderUserInfo =Users();

User? currentFirebaseUser;
String uName = '';

String statusRide = '';
String carDetailsDriver = '';
String driverNameDetails = '';
String driverPhoneDetails = '';

int driverRequestTimeOut = 120;
String rideStatus = 'Driver is Coming';
double starCounter = 0;
String title = '';
String carRideType = '';

String serverKey = "Server_key";
