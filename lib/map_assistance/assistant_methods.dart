import 'dart:convert';
import 'dart:core';
import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:uber_clone/map_assistance/request_assistance.dart';
import 'package:uber_clone/models/address.dart';
import 'package:uber_clone/models/directions.dart';
import 'package:uber_clone/provider/app_data.dart';
import 'package:uber_clone/ui_reuse/widgets/constants.dart';

class AssistantMethods {
  static Future<String> searchCoordinate(Position position, context) async {
    String placeAddress = '';
    String st1, st2, st3;
    String url =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=AIzaSyBsdpz4AX5T6uqLxqJXUgEDtoxd0TIiJ2w";
    var response = await RequestAssistant.getRequest(url);
    if (response != "failed") {
      st1 = response['results'][0]['address_components'][3]['long_name'];
      st2 = response['results'][0]['address_components'][4]['long_name'];
      st3 = response['results'][0]['address_components'][5]['long_name'];
      placeAddress = st1 + ', ' + st2 + ', ' + st3;
      print(placeAddress);
      Address userPickedLocation = Address();
      userPickedLocation.longitude = position.longitude;
      userPickedLocation.latitude = position.latitude;
      userPickedLocation.placeName = placeAddress;
      Provider.of<AppData>(context, listen: false)
          .updateLocation(userPickedLocation);
    }
    return placeAddress;
  }

  static Future<DirectionDetails?> obtainPlaceDirectionDetails(
      LatLng initialPosition, LatLng finalPosition) async {
    String directionUrl =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${initialPosition.latitude},${initialPosition.longitude}&destination=${finalPosition.latitude},${finalPosition.longitude}&key=$mapKey";
    var res = await RequestAssistant.getRequest(directionUrl);
    if (res == 'failed') {
      return null;
    }
    DirectionDetails directionDetails = DirectionDetails();
    directionDetails.encodedPoints =
        res["routes"][0]["overview_polyline"]["points"];

    directionDetails.distanceText =
        res["routes"][0]["legs"][0]["distance"]["text"];
    directionDetails.distanceValue =
        res["routes"][0]["legs"][0]["distance"]["value"];

    directionDetails.durationText =
        res["routes"][0]["legs"][0]["duration"]["text"];
    directionDetails.durationValue =
        res["routes"][0]["legs"][0]["duration"]["value"];

    return directionDetails;
  }

  static int calculateFares(DirectionDetails directionDetails) {
    double timeTravelFare = (directionDetails.durationValue! / 60) * 0.20;
    double distanceTravelFare = (directionDetails.durationValue! / 1000) * 0.20;
    double totalFareAmount = timeTravelFare + distanceTravelFare;

    //add to pkr multiply with 1$ price

    return totalFareAmount.truncate();
  }

  static void getCurrentOnlineUserInfo() async {
    final reference = FirebaseDatabase.instance
        .ref()
        .child("users")
        .child(currentFirebaseUser!.uid);
    reference.get().then((snapshot) {
      if (snapshot.value != null) {
        riderUserInfo!.email = snapshot.child("email").value.toString();
        riderUserInfo!.name = snapshot.child("user").value.toString();
        riderUserInfo!.phone = snapshot.child("phone").value.toString();
        print(riderUserInfo!.email);
        print(riderUserInfo!.phone);
        print(riderUserInfo!.name);
      }
    });
  }
  
  static void statusOfRideRequest(){
    DatabaseReference? rideRequestRef;

     rideRequestRef = FirebaseDatabase.instance
        .ref()
        .child("Ride Request");
    print('eadasdasdasdadaee2131312312c');
     rideRequestRef.child('-Mqy3vWq_mKJy1jd9yQC').get().then((snapshot) {
       if(snapshot.value != null){
         var status = snapshot.child("status").value.toString();
         print('this is the status i want to print');
         print(status);
         var status2 = snapshot.child("rider_name").value.toString();
         print(status2);

       }else{
         print('eadasdasdasdadaeec');
       }
     });
  }

  static double createRandomNumber(int num) {
    var random = Random();
    int radNum = random.nextInt(num);
    return radNum.toDouble();
  }

//https://fcm.googleapis.com/fcm/send
  static sendNotificationToDriver(
      String token, String rideRequestId, context) async {
    var destination =
        Provider.of<AppData>(context, listen: false).dropOffLocation;
    Map<String, String> headersMap = {
      'Content-Type': 'application/json',
      'Authorization': serverKey,
    };

    Map notification = {
      "body": "DropOff Address, ${destination!.placeName}",
      "title": "New Ride Request"
    };

    Map data = {
      "click_action": "FLUTTER_NOTIFICATION_CLICK",
      "id": "1",
      "status": "done",
      "ride_request_id": rideRequestId
    };

    Map sendNotification = {
      'notification': notification,
      'data': data,
      "priority": "high",
      "to": token
    };

    var res = await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: headersMap,body: jsonEncode(sendNotification));
  }
}
