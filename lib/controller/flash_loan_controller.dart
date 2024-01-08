
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../views/flash_loan.dart';

class FlashLoanController{
  late final String token;
  late final String memberId;
  // final String _url = "https://sojrelsacco.com/api/v1";
  final String _url = "https://known-krill-greatly.ngrok-free.app/api/v1";


  applyFlashLoan(data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token')!;
    String apiUrl = "/flash/add";
    String fullUrl = _url+apiUrl;
    try {
      return await http.post(Uri.parse(
          fullUrl),
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
    String apiUrl = "/flash/get/$memberId";
    String fullUrl = _url+apiUrl;
    try {
      return await http.get(Uri.parse(
          fullUrl),
        headers: _setHeaders(token),
      );
    }
    catch(e){
      print(e.toString());
    }
  }

  getLoanTotalRepaidAmount(loanId) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token')!;
    String apiUrl = "/flash/loan-repayment-amount/$loanId";
    String fullUrl = _url+apiUrl;
    try {
      return await http.get(Uri.parse(
          fullUrl),
        headers: _setHeaders(token),
      );
    }
    catch(e){
      print(e.toString());
    }
  }
  getLoanLimit() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token')!;
    String? id = prefs.getString("id");
    String apiUrl = "/flash/get-limit/$id";
    String fullUrl = _url+apiUrl;
    try {
      return await http.get(Uri.parse(
          fullUrl),
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