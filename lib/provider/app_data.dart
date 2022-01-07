import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:uber_clone/models/address.dart';

class AppData with ChangeNotifier {
  Address? pickUpLocation, dropOffLocation;

  void updateLocation(Address pickUpLocation) {
    this.pickUpLocation = pickUpLocation;
    notifyListeners();
  }

  void updateDropOffLocation(Address dropOffLocation) {
    this.dropOffLocation = dropOffLocation;
    notifyListeners();
  }
}
