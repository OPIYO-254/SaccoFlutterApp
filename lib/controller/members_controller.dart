import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MembersApi{
  // final String _url = 'http://10.0.2.2:8080/api/member/get-all';
  // final String _url = 'https://sojrelsacco.com/api/member/get-all';
  final String _url = "https://known-krill-greatly.ngrok-free.app/api/member/get-all";
  late final String token;

  getAllMembers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token')!;
    try {
      return await http.get(
        Uri.parse(_url),
        headers: _setHeaders(),
      );
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