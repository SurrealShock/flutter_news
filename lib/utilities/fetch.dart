import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class GetFromUrl {
  var _loaded = false;
  var loadedJson;

  dynamic fetch(String url) async {
    if (!_loaded) {
      final httpGet = await http.get(url);
      print("Got from URL.");
      _loaded = true;
      loadedJson = json.decode(httpGet.body);
      return loadedJson;
    }
    print("Loaded from storage");
    return loadedJson;
  }
}