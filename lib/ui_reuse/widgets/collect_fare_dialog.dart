import 'package:flutter/material.dart';

class CollectFareDialog extends StatelessWidget {
  final String? paymentMethod;
  final int? fareAmount;

  CollectFareDialog({this.paymentMethod, this.fareAmount});

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
            Text('Trip Fare'),

            Divider(height: 2,),
            SizedBox(
              height: 16,
            ),
            Text(
              '\$$fareAmount',
              style: TextStyle(fontSize: 55, fontFamily: "Semibold"),
            ),
            SizedBox(
              height: 16,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'This is the total trip amount,charged by Driver',
                style: TextStyle(fontSize: 15, fontFamily: "Semibold"),
              ),
            ),
            SizedBox(
              height: 16,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: RaisedButton(
                color: Colors.deepPurpleAccent,
                onPressed: () async {
                  Navigator.pop(context,"close");
                },
                child: Padding(
                  padding: const EdgeInsets.all(17),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Pay cash",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold),
                      ),
                      Icon(
                        Icons.attach_money,
                        size: 26,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 10,)

          ],
        ),
      ),
    );
  }
}
