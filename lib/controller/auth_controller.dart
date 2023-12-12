import 'dart:convert';
import 'package:http/http.dart' as http;
class AuthApi{
  final String _url = 'https://known-krill-greatly.ngrok-free.app/api/auth';
  postUser(data, apiUrl) async {
    try {
      var fillUrl = _url + apiUrl;
      return await http.post(Uri.parse(
          fillUrl),
        body: jsonEncode(data),
        headers: _setHeaders(),
      );
    }
    catch(e){
      print(e.toString());
    }
  }
  Map<String, String> _setHeaders() {
    return {
      'Content-type': 'application/json',
      'Accept': 'application/json',
    };
  }



}