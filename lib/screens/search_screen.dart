import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:uber_clone/map_assistance/assistant_methods.dart';
import 'package:uber_clone/map_assistance/request_assistance.dart';
import 'package:uber_clone/models/address.dart';
import 'package:uber_clone/models/place_prediction.dart';
import 'package:uber_clone/provider/app_data.dart';
import 'package:uber_clone/ui_reuse/widgets/constants.dart';
import 'package:uber_clone/ui_reuse/widgets/divider.dart';
import 'package:uber_clone/ui_reuse/widgets/progress_dialog.dart';

class SearchScreen extends StatefulWidget {
  static final String routeName = 'search';

  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController pickUpTextEditingController = TextEditingController();
  TextEditingController dropOffTextEditingController = TextEditingController();
  List<PlacePredictions> placePredictionList = [];


  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  @override
  void initState() {
    AssistantMethods.getCurrentOnlineUserInfo();    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    String placeAddress =
        Provider.of<AppData>(context).pickUpLocation!.placeName ?? "";
    pickUpTextEditingController.text = placeAddress;
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Column(
          children: [
            Container(
              height: 230,
              decoration: BoxDecoration(color: Colors.white, boxShadow: [
                BoxShadow(
                    color: Colors.blueGrey,
                    blurRadius: 6.0,
                    spreadRadius: 0.5,
                    offset: Offset(0.7, 0.7))
              ]),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 22.0),
                child: Column(
                  children: [
                    SizedBox(
                      height: 5.0,
                    ),
                    Stack(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Icon(Icons.arrow_back),
                        ),
                        Center(
                          child: Text(
                            'Set Drop Off',
                            style: TextStyle(
                                fontSize: 18.0, fontFamily: 'Semibold'),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 16.0,
                    ),
                    Row(
                      children: [
                        Image.asset(
                          'assets/images/pickicon.png',
                          height: 16,
                          width: 16,
                        ),
                        SizedBox(
                          width: 18,
                        ),
                        Expanded(
                            child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: TextField(
                              controller: pickUpTextEditingController,
                              decoration: InputDecoration(
                                  hintText: "pickUp location ",
                                  fillColor: Colors.grey[400],
                                  filled: true,
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.only(
                                      left: 11, top: 8, bottom: 8)),
                            ),
                          ),
                        ))
                      ],
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Row(
                      children: [
                        Image.asset(
                          'assets/images/desticon.png',
                          height: 16,
                          width: 16,
                        ),
                        SizedBox(
                          width: 18,
                        ),
                        Expanded(
                            child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: TextField(
                              onChanged: (val) {
                                findPlace(val);
                              },
                              controller: dropOffTextEditingController,
                              decoration: InputDecoration(
                                  hintText: "Drop Off location ",
                                  fillColor: Colors.grey[400],
                                  filled: true,
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.only(
                                      left: 11, top: 8, bottom: 8)),
                            ),
                          ),
                        ))
                      ],
                    )
                  ],
                ),
              ),
            ),
            (placePredictionList.length > 0)
                ? Column(
                    children: [
                      Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        child: ListView.separated(
                          padding: EdgeInsets.all(0),
                          itemBuilder: (context, index) {
                            return PredictionTile(
                                placePredictions: placePredictionList[index]);
                          },
                          separatorBuilder: (BuildContext context, int index) =>
                              DividerWidget(),
                          itemCount: placePredictionList.length,
                          physics: ClampingScrollPhysics(),
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                        ),
                      ),
                    ],
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  void findPlace(String placeName) async {
    if (placeName.length > 1) {
      String autoComplete =
          'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$placeName&key=$mapKey&sessiontoken=1234567890&components=country:pk';
      var res = await RequestAssistant.getRequest(autoComplete);
      if (res == 'failed') {
        return;
      }
      if (res["status"] == "OK") {
        var predictions = res["predictions"];
        var placesList = (predictions as List)
            .map((e) => PlacePredictions.fromJson(e))
            .toList();
        setState(() {
          placePredictionList = placesList;
        });
      }
    }
  }
}

class PredictionTile extends StatelessWidget {
  final PlacePredictions placePredictions;

  const PredictionTile({Key? key, required this.placePredictions})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        getPlaceAddressDetails(placePredictions.place_id!, context);
      },
      child: Container(
          child: Column(
        children: [
          SizedBox(
            width: 18,
          ),
          Row(
            children: [
              Icon(
                Icons.add_location,
                color: Colors.green,
              ),
              SizedBox(
                width: 14,
              ),
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      placePredictions.main_text!,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 16,color: Colors.white),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      placePredictions.secondary_text!,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ))
            ],
          ),
          SizedBox(
            width: 10,
          ),
        ],
      )),
    );
  }

  void getPlaceAddressDetails(String placeId, context) async {


    showDialog(
        context: context,
        builder: (BuildContext context) => ProgressDialog("please wait"));

    String placeDetails =
        "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$mapKey";
    var res = await RequestAssistant.getRequest(placeDetails);
    Navigator.pop(context);
    if(res == "failed"){
      return;
    }
    if(res['status'] == 'OK'){


      Address address = Address();
      address.placeName = res["result"]["name"];
      address.placeId = placeId;
      address.latitude = res["result"]["geometry"]["location"]["lat"];
      address.longitude = res["result"]["geometry"]["location"]["lng"];

      Provider.of<AppData>(context,listen: false).updateDropOffLocation(address);
      print("this is drop Off:");
      print(address.placeName);
      Navigator.pop(context,"obtainDirection");
    }
  }
}
