
// import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
// import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MemberApi{
  // final String _url = 'http://10.0.2.2:8080/api';
  // final String _url = 'https://sojrelsacco.com/api';
  final String _url = "https://known-krill-greatly.ngrok-free.app/api";
  late final String token;
  late final String id;

  getMember() async {
    // Retrieve token from SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token')!;
    id = prefs.getString("id")!;
    String apiUrl="/member/get/$id";

    try {
      var fullUrl = _url + apiUrl;
      return await http.get(Uri.parse(fullUrl),
          headers: _setHeaders());
    }
    on ClientException catch(ex) {
      print(ex.toString());
    }
    catch(e){
      print(e.toString());
    }
  }

  getPhotoUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token')!;
    id = prefs.getString("id")!;
    String apiUrl="/files/photo-image/$id";
    try {
      var fullUrl = _url + apiUrl;
      return await http.get(Uri.parse(fullUrl),
          headers: _setHeaders());
    }
    on ClientException catch(ex) {
      print(ex.toString());
    }
    catch(e){
      print(e.toString());
    }
  }

  Map<String, String> _setHeaders() {
    return {
      'Authorization': 'Bearer $token',
      'Content-type': 'application/json',
      'Accept': 'application/json',
    };
  }
}