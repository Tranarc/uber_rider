import 'package:flutter/material.dart';
import 'package:uber_clone/screens/auth/intro.dart';

///this dart file for testing google map and api testing only

class NewPage extends StatefulWidget {
  static final String routeName = 'some';

  const NewPage({Key? key}) : super(key: key);

  @override
  _NewPageState createState() => _NewPageState();
}

class _NewPageState extends State<NewPage> {
  String rideRequestId = "-Mqy3vWq_mKJy1jd9yQC";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => WelcomePage()));
              },
              child: Text("Get email")),
          SizedBox(
            height: 10,
          ),
          // Text(rideDetails!.payment_method!.toString() ),
          SizedBox(
            height: 10,
          ),
          ElevatedButton(onPressed: () {}, child: Text("Get username")),
          SizedBox(
            height: 10,
          ),
          ElevatedButton(onPressed: () {}, child: Text("Get Number")),
        ],
      ),
    );
  }
}
