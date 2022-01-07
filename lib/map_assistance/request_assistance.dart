import 'package:http/http.dart' as http;

import 'dart:convert';



class RequestAssistant {
  static Future<dynamic> getRequest(String url) async {
    final response = await http.get(Uri.parse(url));
    try {
      if (response.statusCode == 200) {
        String data = response.body;
        var decodeData = jsonDecode(data);
        return decodeData;
      }
      else{
        return "failed";
      }
    } catch (err) {
      return "failed";
    }
  }
}
