import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:uber_clone/main.dart';
import 'package:uber_clone/map_assistance/assistant_methods.dart';
import 'package:uber_clone/map_assistance/geofire_assistant.dart';
import 'package:uber_clone/models/allUsers.dart';
import 'package:uber_clone/models/directions.dart';
import 'package:uber_clone/models/geofire.dart';
import 'package:uber_clone/provider/app_data.dart';
import 'package:uber_clone/screens/auth/signup.dart';
import 'package:uber_clone/screens/rating_screen.dart';
import 'package:uber_clone/screens/search_screen.dart';
import 'package:uber_clone/ui_reuse/widgets/SearchingRideBox.dart';
import 'package:uber_clone/ui_reuse/widgets/collect_fare_dialog.dart';
import 'package:uber_clone/ui_reuse/widgets/constants.dart';
import 'package:uber_clone/ui_reuse/widgets/drawer_container.dart';
import 'package:uber_clone/ui_reuse/widgets/no_driver_dialog.dart';
import 'package:uber_clone/ui_reuse/widgets/positioned_widget_drawer.dart';
import 'package:uber_clone/ui_reuse/widgets/progress_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

class MainScreen extends StatefulWidget {
  static final String routeName = 'mainScreen';

  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  Completer<GoogleMapController> _controllerGoogleMap = Completer();
  late GoogleMapController newGoogleMapController;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(31.46294, 73.12506),
    zoom: 14.4746,
  );

  final _animationDuration = Duration(seconds: 2);
  Timer? _timer;
  Color? _color;

  double rideDetailsContainer = 0;
  double searchContainerHeight = 300;
  double requestRideContainer = 0;
  double driverDetailsContainerHeight = 0;

  bool nearbyAvailableDriverLoaded = false;

  BitmapDescriptor? nearByIcon;

  List<NearbyAvailableDrivers>? availableDrivers;

  String state = 'normal';
  StreamSubscription<DatabaseEvent>? rideStreamSubscription;

  DatabaseReference? rideRequestRef;
  Users? currentUser;

  static const colorizeColors = [
    Colors.green,
    Colors.purple,
    Colors.pink,
    Colors.blue,
    Colors.yellow,
    Colors.red,
  ];

  static const colorizeTextStyle = TextStyle(
    fontSize: 55.0,
    fontFamily: 'Signatra',
  );

  void displayRequestContainer() {
    setState(() {
      requestRideContainer = 270;
      rideDetailsContainer = 0;
      bottomPadding = 260;
      drawerOpen = true;
    });
    saveRideReq();
  }

  void displayDriverDetailsContainer() {
    setState(() {
      requestRideContainer = 0;
      rideDetailsContainer = 0;
      bottomPadding = 330;
      driverDetailsContainerHeight = 320;
    });
  }

  resetApp() {
    setState(() {
      drawerOpen = true;

      searchContainerHeight = 300;
      rideDetailsContainer = 0;
      requestRideContainer = 0;

      bottomPadding = 260;

      polyLineSet.clear();
      markersSet.clear();
      circlesSet.clear();
      pLineCoordinates.clear();

      statusRide = '';
      driverNameDetails = '';
      driverPhoneDetails = '';
      carDetailsDriver = '';
      rideStatus = 'Driver is Coming';
      driverDetailsContainerHeight = 0;
    });
    locatePosition();
  }

  void displayRIdesDetailsContainer() async {
    await getDirection();

    setState(() {
      searchContainerHeight = 0;
      rideDetailsContainer = 340;
      bottomPadding = 360;
      drawerOpen = false;
    });
  }

  List<LatLng> pLineCoordinates = [];
  Set<Polyline> polyLineSet = {};

  Set<Marker> markersSet = {};
  Set<Circle> circlesSet = {};

  DirectionDetails? tripDirectionDetails;

  Position? currentPosition;
  var geoLocator = Geolocator();

  double bottomPadding = 0;

  bool drawerOpen = true;

  void locatePosition() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    currentPosition = position;

    LatLng latLngPosition = LatLng(position.latitude, position.longitude);

    CameraPosition cameraPosition =
        CameraPosition(target: latLngPosition, zoom: 14);
    newGoogleMapController
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    String address = await AssistantMethods.searchCoordinate(position, context);
    print("this is your address:" + address);

    initGeoFireListener();

    uName = riderUserInfo!.name!;
  }

  @override
  void initState() {
    AssistantMethods.statusOfRideRequest();
    _timer = Timer.periodic(_animationDuration, (timer) => _changeColor());
    _color = Colors.grey;
    super.initState();
  }

  void _changeColor() {
    final newColor = _color == Colors.grey ? Colors.blueGrey : Colors.grey;
    setState(() {
      _color = newColor;
    });
  }

  void saveRideReq() {
    rideRequestRef =
        FirebaseDatabase.instance.ref().child("Ride Request").push();

    var pickUp = Provider.of<AppData>(context, listen: false).pickUpLocation;
    var dropOff = Provider.of<AppData>(context, listen: false).dropOffLocation;

    Map pickUpLocMap = {
      "latitude": pickUp!.latitude.toString(),
      "longitude": pickUp.longitude.toString(),
    };

    Map dropOffLocMAp = {
      "latitude": dropOff!.latitude.toString(),
      "longitude": dropOff.longitude.toString(),
    };

    Map rideInfoMap = {
      "driver_id": "waiting",
      "payment_method": "cash",
      "pickUp": pickUpLocMap,
      "dropOff": dropOffLocMAp,
      "created_at": DateTime.now().toString(),
      "rider_name": riderUserInfo!.name,
      "rider_phone": riderUserInfo!.phone,
      "pickup_address": pickUp.placeName,
      "dropOff_address": dropOff.placeName,
      "ride_type": carRideType,
    };

    rideRequestRef!.set(rideInfoMap);

    rideStreamSubscription = rideRequestRef!.onValue.listen((event) async {
      if (event.snapshot.value == null) {
        return;
      }
      if (event.snapshot.child('car_details').value != null) {
        setState(() {
          carDetailsDriver =
              event.snapshot.child('car_details').value.toString();
        });
      }
      if (event.snapshot.child('driver_name').value != null) {
        setState(() {
          driverNameDetails =
              event.snapshot.child('driver_name').value.toString();
        });
      }
      if (event.snapshot.child('driver_phone').value != null) {
        setState(() {
          driverPhoneDetails =
              event.snapshot.child('driver_phone').value.toString();
        });
      }
      if (event.snapshot.child('driver_location').value != null) {
        double driverLat = double.parse(event.snapshot
            .child('driver_location')
            .child('latitude')
            .value
            .toString());
        double driverLng = double.parse(event.snapshot
            .child('driver_location')
            .child('longitude')
            .value
            .toString());

        LatLng driverCurrentLocation = LatLng(driverLat, driverLng);

        if (statusRide == "accepted") {
          updateRideTime(driverCurrentLocation);
        } else if (statusRide == "onride") {
          updateRideTimeDropOutLoc(driverCurrentLocation);
        } else if (statusRide == "arrived") {
          setState(() {
            rideStatus = "Driver has been arrived";
          });
        }
      }

      if (event.snapshot.child('status').value != null) {
        statusRide = event.snapshot.child('status').value.toString();
      }
      print(carDetailsDriver);
      print(driverPhoneDetails);
      print(statusRide);
      if (statusRide == "accepted") {
        displayDriverDetailsContainer();
        Geofire.stopListener();
        deleteGeoFireMarkers();
      }
      if (statusRide == 'ended') {
        if (event.snapshot.child("fares").value.toString() != null) {
          int fare = int.parse(event.snapshot.child("fares").value.toString());
          var res = await showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) =>
                  CollectFareDialog(paymentMethod: "cash", fareAmount: fare));

          String driverId = '';
          if (res == "close") {
            if (event.snapshot.child("driver_id").value.toString() != null) {
              driverId = event.snapshot.child("driver_id").value.toString();
            }
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => RatinfScreen(driverId)));
            rideRequestRef!.onDisconnect();
            rideRequestRef = null;
            rideStreamSubscription!.cancel();
            rideStreamSubscription = null;
            resetApp();
          }
        }
      }
    });
  }

  bool _visible = true;

  bool isRequestedPosition = false;

  void deleteGeoFireMarkers() {
    setState(() {
      markersSet
          .removeWhere((element) => element.markerId.value.contains("drivers"));
    });
  }

  void updateRideTime(LatLng driverCurrentLocation) async {
    if (isRequestedPosition == false) {
      isRequestedPosition = true;
      var positionUserLatLng =
          LatLng(currentPosition!.latitude, currentPosition!.longitude);
      var details = await AssistantMethods.obtainPlaceDirectionDetails(
          driverCurrentLocation, positionUserLatLng);

      if (details == null) {
        return;
      }
      setState(() {
        rideStatus = 'Driver is Coming -' + details.durationText!;
      });

      isRequestedPosition = false;
    }
  }

  void updateRideTimeDropOutLoc(LatLng driverCurrentLocation) async {
    if (isRequestedPosition == false) {
      isRequestedPosition = true;
      var dropOff =
          Provider.of<AppData>(context, listen: false).dropOffLocation;
      var dropOffLatLng = LatLng(dropOff!.latitude!, dropOff.longitude!);
      var details = await AssistantMethods.obtainPlaceDirectionDetails(
          driverCurrentLocation, dropOffLatLng);

      if (details == null) {
        return;
      }
      setState(() {
        rideStatus = 'going to direction -' + details.durationText!;
      });

      isRequestedPosition = false;
    }
  }

  void cancelRequest() {
    rideRequestRef!.remove();
    setState(() {
      state = 'normal';
    });
  }

  @override
  void dispose() {
    _timer!.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    createIconMarker();
    return Scaffold(
      key: scaffoldKey,
      drawer: DrawerContainer(),
      body: Builder(builder: (BuildContext contexg) {
        return OfflineBuilder(
          connectivityBuilder: (BuildContext context,
              ConnectivityResult connectivity, Widget child) {
            final bool connected = connectivity != ConnectivityResult.none;
            return Stack(
              fit: StackFit.expand,
              children: [
                child,
                Positioned(
                  left: 0.0,
                  right: 0.0,
                  height: 32.0,
                  child: connected
                      ? Container()
                      : Visibility(
                          visible: connected ? _visible : _visible = true,
                          maintainSize: true,
                          maintainAnimation: true,
                          maintainState: true,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            color: connected
                                ? Color(0xFF00EE44)
                                : Color(0xFFEE4400),
                            child: connected
                                ? Center(
                                    child: Text(
                                      "ONLINE",
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        "OFFLINE",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      SizedBox(
                                        width: 8.0,
                                      ),
                                      SizedBox(
                                        width: 12.0,
                                        height: 12.0,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.0,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                ),
              ],
            );
          },
          child: Stack(
            children: [
              GoogleMap(
                padding: EdgeInsets.only(bottom: bottomPadding),
                initialCameraPosition: _kGooglePlex,
                myLocationButtonEnabled: true,
                mapType: MapType.normal,
                myLocationEnabled: true,
                zoomGesturesEnabled: true,
                zoomControlsEnabled: true,
                polylines: polyLineSet,
                markers: markersSet,
                circles: circlesSet,
                onMapCreated: (GoogleMapController controller) {
                  _controllerGoogleMap.complete(controller);
                  newGoogleMapController = controller;
                  rootBundle
                      .loadString('assets/images/light.txt')
                      .then((string) {
                    newGoogleMapController.setMapStyle(string);
                  });
                  setState(() {
                    bottomPadding = 320.0;
                  });
                  locatePosition();
                },
              ),
              DrawerPositionedWidget(
                press: () => drawerOpen
                    ? scaffoldKey.currentState!.openDrawer()
                    : resetApp(),
                iconData: drawerOpen ? Icons.menu : Icons.close,
              ),
              Positioned(
                left: 0.0,
                right: 0.0,
                bottom: 0.0,
                child: AnimatedSize(
                  vsync: this,
                  curve: Curves.bounceIn,
                  duration: new Duration(milliseconds: 130),
                  child: Container(
                    height: searchContainerHeight,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15.0),
                      ),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black45,
                            blurRadius: 17,
                            spreadRadius: 0.5,
                            offset: Offset(0.7, 0.7))
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 18, horizontal: 24),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hi there',
                              style: TextStyle(
                                  fontSize: 12.0, fontFamily: 'Semibold'),
                            ),
                            Text(
                              'Where to?',
                              style: TextStyle(
                                  fontSize: 20.0, fontFamily: "Semibold"),
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    var res = await Navigator.pushNamed(
                                        context, SearchScreen.routeName);
                                    if (res == "obtainDirection") {
                                      displayRIdesDetailsContainer();
                                    }
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: AnimatedContainer(
                                      width: 100,
                                      height: 100,
                                      duration: _animationDuration,
                                      color: _color,
                                      child: Icon(
                                        Icons.search,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 6,
                                ),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: AnimatedContainer(
                                    width: 100,
                                    height: 100,
                                    duration: _animationDuration,
                                    color: _color,
                                    child: Icon(
                                      Icons.home,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 6,
                                ),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: AnimatedContainer(
                                    width: 100,
                                    height: 100,
                                    duration: _animationDuration,
                                    color: _color,
                                    child: Icon(
                                      Icons.work,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              //confirm_request
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: AnimatedSize(
                  vsync: this,
                  curve: Curves.bounceIn,
                  duration: new Duration(milliseconds: 160),
                  child: Container(
                    height: rideDetailsContainer,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(16),
                            topLeft: Radius.circular(16)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black,
                            blurRadius: 16,
                            spreadRadius: 0.5,
                            offset: Offset(0.7, 0.7),
                          )
                        ]),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            SizedBox(
                              height: 10,
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  state = 'requesting';
                                  carRideType = 'uber_x';
                                });
                                displayRequestContainer();
                                availableDrivers =
                                    GeofireAssistant.nearbyAvailableDriver;
                                searchNearestDriver();
                              },
                              child: Container(
                                width: double.infinity,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  child: Row(
                                    children: [
                                      Image.asset(
                                        "assets/images/UberX.png",
                                        height: 70,
                                        width: 80,
                                      ),
                                      SizedBox(
                                        width: 16,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "UberX",
                                            style: TextStyle(
                                                fontSize: 18.0,
                                                fontFamily: "Semibold"),
                                          ),
                                          Text(
                                            ((tripDirectionDetails != null)
                                                ? tripDirectionDetails!
                                                    .distanceText!
                                                : ""),
                                            style: TextStyle(
                                                fontSize: 16.0,
                                                fontFamily: "Semibold",
                                                color: Colors.green),
                                          ),
                                        ],
                                      ),
                                      Expanded(child: Container()),
                                      Text(
                                        ((tripDirectionDetails != null)
                                            ? "\$${(AssistantMethods.calculateFares(tripDirectionDetails!)) * 2}"
                                            : ""),
                                        style: TextStyle(
                                            fontSize: 16.0,
                                            fontFamily: "Semibold",
                                            color: Colors.green),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Divider(
                              height: 3,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  state = 'requesting';
                                  carRideType = 'uber_go';
                                });
                                displayRequestContainer();
                                availableDrivers =
                                    GeofireAssistant.nearbyAvailableDriver;
                                searchNearestDriver();
                              },
                              child: Container(
                                width: double.infinity,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  child: Row(
                                    children: [
                                      Image.asset(
                                        "assets/images/UberX.png",
                                        height: 70,
                                        width: 80,
                                      ),
                                      SizedBox(
                                        width: 16,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Uber mini",
                                            style: TextStyle(
                                                fontSize: 18.0,
                                                fontFamily: "Semibold"),
                                          ),
                                          Text(
                                            ((tripDirectionDetails != null)
                                                ? tripDirectionDetails!
                                                    .distanceText!
                                                : ""),
                                            style: TextStyle(
                                                fontSize: 16.0,
                                                fontFamily: "Semibold",
                                                color: Colors.green),
                                          ),
                                        ],
                                      ),
                                      Expanded(child: Container()),
                                      Text(
                                        ((tripDirectionDetails != null)
                                            ? "\$${AssistantMethods.calculateFares(tripDirectionDetails!)}"
                                            : ""),
                                        style: TextStyle(
                                            fontSize: 16.0,
                                            fontFamily: "Semibold",
                                            color: Colors.green),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Divider(
                              height: 3,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  state = 'requesting';
                                  carRideType = 'bike';
                                });
                                displayRequestContainer();
                                availableDrivers =
                                    GeofireAssistant.nearbyAvailableDriver;
                                searchNearestDriver();
                              },
                              child: Container(
                                width: double.infinity,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  child: Row(
                                    children: [
                                      Image.asset(
                                        "assets/images/Moto.png",
                                        height: 70,
                                        width: 80,
                                      ),
                                      SizedBox(
                                        width: 16,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Bike",
                                            style: TextStyle(
                                                fontSize: 18.0,
                                                fontFamily: "Semibold"),
                                          ),
                                          Text(
                                            ((tripDirectionDetails != null)
                                                ? tripDirectionDetails!
                                                    .distanceText!
                                                : ""),
                                            style: TextStyle(
                                                fontSize: 16.0,
                                                fontFamily: "Semibold",
                                                color: Colors.green),
                                          ),
                                        ],
                                      ),
                                      Expanded(child: Container()),
                                      Text(
                                        ((tripDirectionDetails != null)
                                            ? "\$${(AssistantMethods.calculateFares(tripDirectionDetails!) / 2)}"
                                            : ""),
                                        style: TextStyle(
                                            fontSize: 16.0,
                                            fontFamily: "Semibold",
                                            color: Colors.green),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20.0),
                              child: Row(
                                children: [
                                  Icon(
                                    FontAwesomeIcons.moneyBillAlt,
                                    size: 18,
                                    color: Colors.black54,
                                  ),
                                  SizedBox(
                                    width: 16,
                                  ),
                                  Text("Cash"),
                                  SizedBox(
                                    width: 6,
                                  ),
                                  Icon(
                                    Icons.keyboard_arrow_down,
                                    size: 16,
                                    color: Colors.black54,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 24,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              //assign_driver_info
              Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: driverDetailsContainerHeight,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(16),
                            topLeft: Radius.circular(16)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black,
                            blurRadius: 16,
                            spreadRadius: 0.5,
                            offset: Offset(0.7, 0.7),
                          )
                        ]),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30.0, vertical: 18.0),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 12,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                rideStatus,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 20, fontFamily: "Semibold"),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 12,
                          ),
                          Divider(
                            height: 2,
                          ),
                          Text(
                            carDetailsDriver,
                            style: TextStyle(fontSize: 20),
                          ),
                          Text(
                            driverNameDetails,
                            style: TextStyle(fontSize: 20),
                          ),
                          SizedBox(
                            height: 12,
                          ),
                          Divider(
                            height: 2,
                          ),
                          SizedBox(
                            height: 12,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Column(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      launch(('tel://$driverPhoneDetails'));
                                    },
                                    child: Container(
                                      width: 60,
                                      height: 55,
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(25)),
                                          border: Border.all(
                                              width: 2, color: Colors.grey)),
                                      child: Icon(
                                        Icons.call,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text('call'),
                                ],
                              ),
                              Column(
                                children: [
                                  Container(
                                    width: 60,
                                    height: 55,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(25)),
                                        border: Border.all(
                                            width: 2, color: Colors.grey)),
                                    child: Icon(
                                      Icons.list,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text('Details'),
                                ],
                              ),
                              Column(
                                children: [
                                  Container(
                                    width: 60,
                                    height: 55,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(25)),
                                        border: Border.all(
                                            width: 2, color: Colors.grey)),
                                    child: Icon(
                                      Icons.cancel,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text('cancel'),
                                ],
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  )),

              //request_rider
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: requestRideContainer,
                  child: SearchingRideBox(
                    onTap: () {
                      cancelRequest();
                      resetApp();
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Future<void> getDirection() async {
    var initialPos =
        Provider.of<AppData>(context, listen: false).pickUpLocation;
    var finalPos = Provider.of<AppData>(context, listen: false).dropOffLocation;

    var pickUpLatLng = LatLng(initialPos!.latitude!, initialPos.longitude!);
    var dropOffLatLng = LatLng(finalPos!.latitude!, finalPos.longitude!);

    showDialog(
        context: context,
        builder: (BuildContext context) => ProgressDialog(" Please wait...."));

    var details = await AssistantMethods.obtainPlaceDirectionDetails(
        pickUpLatLng, dropOffLatLng);
    setState(() {
      tripDirectionDetails = details;
    });

    Navigator.of(context).pop();

    print("This is encoded Path");
    print(details!.encodedPoints);

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> decodePolyLineResult =
        polylinePoints.decodePolyline(details.encodedPoints!);

    pLineCoordinates.clear();

    if (decodePolyLineResult.isNotEmpty) {
      decodePolyLineResult.forEach((PointLatLng pointLatLng) {
        pLineCoordinates
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }

    polyLineSet.clear();
    setState(() {
      Polyline polyline = Polyline(
          polylineId: PolylineId("PolylineId"),
          color: Colors.pink,
          jointType: JointType.round,
          width: 5,
          points: pLineCoordinates,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          geodesic: true);

      polyLineSet.add(polyline);
      print(polyLineSet);
    });
    LatLngBounds latLngBounds;
    if (pickUpLatLng.latitude > dropOffLatLng.latitude &&
        pickUpLatLng.longitude > dropOffLatLng.longitude) {
      latLngBounds =
          LatLngBounds(southwest: dropOffLatLng, northeast: pickUpLatLng);
    } else if (pickUpLatLng.longitude > dropOffLatLng.longitude) {
      latLngBounds = LatLngBounds(
        southwest: LatLng(pickUpLatLng.latitude, dropOffLatLng.latitude),
        northeast: LatLng(dropOffLatLng.longitude, pickUpLatLng.longitude),
      );
    } else if (pickUpLatLng.latitude > dropOffLatLng.latitude) {
      latLngBounds = LatLngBounds(
        southwest: LatLng(dropOffLatLng.latitude, pickUpLatLng.latitude),
        northeast: LatLng(pickUpLatLng.longitude, dropOffLatLng.longitude),
      );
    } else {
      latLngBounds =
          LatLngBounds(southwest: pickUpLatLng, northeast: dropOffLatLng);
    }
    newGoogleMapController
        .animateCamera(CameraUpdate.newLatLngBounds(latLngBounds, 70));
    Marker pickUpLocMarker = Marker(
      markerId: MarkerId("pickUpId"),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
      infoWindow:
          InfoWindow(title: initialPos.placeName, snippet: "my location"),
      position: pickUpLatLng,
    );
    Marker dropOffLocMarker = Marker(
      markerId: MarkerId("dropOffId"),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      infoWindow:
          InfoWindow(title: finalPos.placeName, snippet: "DropOff Location"),
      position: dropOffLatLng,
    );

    setState(() {
      markersSet.add(pickUpLocMarker);
      markersSet.add(dropOffLocMarker);
    });

    Circle pickUpCircle = Circle(
      circleId: CircleId("pickUpId"),
      fillColor: Colors.blueAccent,
      radius: 12,
      center: pickUpLatLng,
      strokeWidth: 4,
      strokeColor: Colors.yellowAccent,
    );

    Circle dropOffCircle = Circle(
      circleId: CircleId("dropOffId"),
      fillColor: Colors.deepPurple,
      radius: 12,
      center: dropOffLatLng,
      strokeWidth: 4,
      strokeColor: Colors.deepPurple,
    );
    setState(() {
      circlesSet.add(pickUpCircle);
      circlesSet.add(dropOffCircle);
    });
  }

  void initGeoFireListener() {
    Geofire.initialize("availableDrivers");
    Geofire.queryAtLocation(
            currentPosition!.latitude, currentPosition!.longitude, 10)!
        .listen((map) {
      print(map);
      if (map != null) {
        var callBack = map["callBack"];

        switch (callBack) {
          case Geofire.onKeyEntered:
            NearbyAvailableDrivers nearbyAvailableDrivers =
                NearbyAvailableDrivers();
            nearbyAvailableDrivers.key = map["key"];
            nearbyAvailableDrivers.latitude = map["latitude"];
            nearbyAvailableDrivers.longitude = map["longitude"];
            GeofireAssistant.nearbyAvailableDriver.add(nearbyAvailableDrivers);

            if (nearbyAvailableDriverLoaded == true) {
              updateAvailableDriversOnMap();
            }
            break;
          case Geofire.onKeyExited:
            GeofireAssistant.removeDriverFromList(map["key"]);
            updateAvailableDriversOnMap();
            break;
          case Geofire.onKeyMoved:
            NearbyAvailableDrivers nearbyAvailableDrivers =
                NearbyAvailableDrivers();
            nearbyAvailableDrivers.key = map["key"];
            nearbyAvailableDrivers.latitude = map["latitude"];
            nearbyAvailableDrivers.longitude = map["longitude"];
            GeofireAssistant.updateNearbyLocation(nearbyAvailableDrivers);
            updateAvailableDriversOnMap();
            break;
          case Geofire.onGeoQueryReady:
            updateAvailableDriversOnMap();
            break;
        }
      }
    });
  }

  void updateAvailableDriversOnMap() {
    setState(() {
      markersSet.clear();
    });
    Set<Marker> tMarker = Set<Marker>();
    for (NearbyAvailableDrivers driver
        in GeofireAssistant.nearbyAvailableDriver) {
      LatLng driverAvailablePosition =
          LatLng(driver.latitude!, driver.longitude!);
      Marker marker = Marker(
        markerId: MarkerId('driver ${driver.key}'),
        position: driverAvailablePosition,
        icon: nearByIcon!,
        rotation: AssistantMethods.createRandomNumber(360),
      );
      tMarker.add(marker);
    }
    setState(() {
      markersSet = tMarker;
    });
  }

  void createIconMarker() {
    if (nearByIcon == null) {
      ImageConfiguration imageConfiguration =
          createLocalImageConfiguration(context, size: Size(-2, -2));
      BitmapDescriptor.fromAssetImage(
              imageConfiguration, "assets/images/carIcon.png")
          .then((value) {
        nearByIcon = value;
      });
    }
  }

  void noDriverFound() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => NoDriverAvailable());
  }

  void searchNearestDriver() {
    if (availableDrivers!.length == 0) {
      cancelRequest();
      resetApp();
      noDriverFound();
      return;
    }

    var driver = availableDrivers![0];
    driversRef
        .child(driver.key!)
        .child('car_details')
        .child("type")
        .get()
        .then((value) async {
      if (value.value != null) {
        String carType = value.value.toString();
        if (carType == carRideType) {
          notifyDriver(driver);
          availableDrivers!.removeAt(0);
        } else {
          displayToast(carRideType + "not available,try again", context);
        }
      } else {
        displayToast("not car available,try again", context);
      }
    });
  }

  void notifyDriver(NearbyAvailableDrivers driver) {
    driversRef.child(driver.key!).child("newRide").set(rideRequestRef!.key);
    driversRef.child(driver.key!).child("token").get().then((snapshot) {
      if (snapshot.value != null) {
        String token = snapshot.value.toString();
        AssistantMethods.sendNotificationToDriver(
            token, rideRequestRef!.key!, context);
      } else {
        return;
      }

      const oneSecondPassed = Duration(seconds: 1);
      Timer.periodic(oneSecondPassed, (timer) {
        if (state != "requesting") {
          driversRef.child(driver.key!).child("newRide").set("timeout");
          driversRef.child(driver.key!).child("newRide").onDisconnect();
          driverRequestTimeOut = 20;
          timer.cancel();
        }

        driverRequestTimeOut = driverRequestTimeOut - 1;

        driversRef.child(driver.key!).child("newRide").onValue.listen((event) {
          if (event.snapshot.value.toString() == "accepted") {
            driversRef.child(driver.key!).child("newRide").onDisconnect();
            driverRequestTimeOut = 20;
            timer.cancel();
          }
        });

        if (driverRequestTimeOut == 0) {
          driversRef.child(driver.key!).child("newRide").set("timeout");
          driversRef.child(driver.key!).child("newRide").onDisconnect();
          driverRequestTimeOut = 20;
          timer.cancel();

          searchNearestDriver();
        }
      });
    });
  }
}
