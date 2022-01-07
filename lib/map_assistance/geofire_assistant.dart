import 'package:uber_clone/models/geofire.dart';

class GeofireAssistant{
  static List<NearbyAvailableDrivers> nearbyAvailableDriver = [];


  static void removeDriverFromList(String key){
    int index = nearbyAvailableDriver.indexWhere((element) => element.key == key);
    nearbyAvailableDriver.remove(index);
  }
  static void updateNearbyLocation(NearbyAvailableDrivers drivers){
    int index = nearbyAvailableDriver.indexWhere((element) => element.key == drivers.key);
    nearbyAvailableDriver[index].latitude = drivers.latitude;
    nearbyAvailableDriver[index].longitude = drivers.longitude;

  }
}