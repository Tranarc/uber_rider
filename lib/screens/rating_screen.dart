import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'package:uber_clone/ui_reuse/widgets/constants.dart';

class RatinfScreen extends StatefulWidget {
  String? driverId;

  RatinfScreen(this.driverId);

  @override
  _RatinfScreenState createState() => _RatinfScreenState();
}

class _RatinfScreenState extends State<RatinfScreen> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      backgroundColor: Colors.transparent,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 22,
            ),
            Text('Rate the Driver'),
            Divider(
              height: 2,
            ),
            SizedBox(
              height: 16,
            ),
            SmoothStarRating(
              rating: starCounter,
              color: Colors.green,
              allowHalfRating: false,
              starCount: 5,
              size: 45,
              onRated: (value) {
                starCounter = value;
                if (starCounter == 1) {
                  setState(() {
                    title = 'very Bad';
                  });
                }
                if (starCounter == 2) {
                  setState(() {
                    title = ' Bad';
                  });
                }
                if (starCounter == 3) {
                  setState(() {
                    title = 'Good';
                  });
                }
                if (starCounter == 4) {
                  setState(() {
                    title = 'very good';
                  });
                }
                if (starCounter == 5) {
                  setState(() {
                    title = 'Excellent';
                  });
                }
              },
            ),
            SizedBox(
              height: 16,
            ),
            Text(
              title,
              style: TextStyle(
                  fontSize: 65.0, fontFamily: 'Semibold', color: Colors.green),
            ),
            SizedBox(
              height: 16,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: RaisedButton(
                color: Colors.deepPurpleAccent,
                onPressed: () async {
                  DatabaseReference driversRatingRef = FirebaseDatabase.instance
                      .ref()
                      .child("drivers")
                      .child(widget.driverId!)
                      .child('ratings');

                  driversRatingRef.get().then((value) {
                    if(value.value != null){
                      double oldRating = double.parse(value.value.toString());
                      double addRating = oldRating + starCounter;
                      double avgRating = addRating/2;
                      driversRatingRef.set(avgRating.toString());
                    }else{
                      driversRatingRef.set(starCounter.toString());

                    }
                  });
                  Navigator.pop(context, "close");
                },
                child: Padding(
                  padding: const EdgeInsets.all(17),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        "Submit",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            )
          ],
        ),
      ),
    );
  }
}
