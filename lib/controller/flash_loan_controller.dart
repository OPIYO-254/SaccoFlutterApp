
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../views/flash_loan.dart';

class FlashLoanController{
  late final String token;
  late final String memberId;


  applyFlashLoan(data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token')!;
    try {
      return await http.post(Uri.parse(
          "https://known-krill-greatly.ngrok-free.app/api/v1/flash/add"),
        body: jsonEncode(data),
        headers: _setHeaders(token),
      );
    }
    catch(e){
      print(e.toString());
    }
  }

   getAppliedLoans(memberId) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token')!;
    // memberId = prefs.getString('id')!;
    try {
      return await http.get(Uri.parse(
          "https://known-krill-greatly.ngrok-free.app/api/v1/flash/get/$memberId"),
        headers: _setHeaders(token),
      );
    }
    catch(e){
      print(e.toString());
    }

  }

  Map<String, String> _setHeaders(token) {
    return {
      'Authorization': 'Bearer $token',
      'Content-type': 'application/json',
      'Accept': 'application/json',
    };
  }

}