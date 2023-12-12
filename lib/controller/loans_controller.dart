import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class LoansController{
  final String _url = 'https://known-krill-greatly.ngrok-free.app/api/loan/add';
  late final String token;
  late final String id;
  postLoan(data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token')!;
    try {
      return await http.post(Uri.parse(
          _url),
        body: jsonEncode(data),
        headers: _setHeaders(token),
      );
    }
    catch(e){
      print(e.toString());
    }
  }

  getMembersLoans() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    id = prefs.getString("id")!;
    token = prefs.getString('token')!;
    try {
      return await http.get(
        Uri.parse("https://known-krill-greatly.ngrok-free.app/api/loan/get-loans/$id"),
        headers: _setHeaders(token),
      );
    }
    catch(e){
      print(e.toString());
    }
  }

  addGuarantor(loanId, guarantorId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token')!;
    try {
      return await http.post(
        Uri.parse("https://known-krill-greatly.ngrok-free.app/api/loan/add-guarantor/$loanId/$guarantorId"),
        headers: _setHeaders(token),
      );
    }
    catch(e){
      print(e.toString());
    }
  }

  getLoanGuarantors(loanId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token')!;
    try {
      return await http.get(
        Uri.parse("https://known-krill-greatly.ngrok-free.app/api/loan/get-one/$loanId"),
        headers: _setHeaders(token),
      );
    }
    catch(e){
      print(e.toString());
    }
  }

  getGuaranteedAmount(loanId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token')!;
    try {
      return await http.get(
        Uri.parse("https://known-krill-greatly.ngrok-free.app/api/loan/get-guarantors/$loanId"),
        headers: _setHeaders(token),
      );
    }
    catch(e){
      print(e.toString());
    }
  }

  getLoanDetails(loanId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token')!;
    try {
      return await http.get(
        // Uri.parse("http://10.0.2.2:8080/api/loan/loan-details/$loanId"),
        Uri.parse("https://known-krill-greatly.ngrok-free.app/api/loan/loan-details/$loanId"),
        headers: _setHeaders(token),
      );
    }
    catch(e){
      print(e.toString());
    }
  }

  getAllLoans() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token')!;
    try {
      return await http.get(
        // Uri.parse("http://10.0.2.2:8080/api/loan/get-all"),
        Uri.parse("https://known-krill-greatly.ngrok-free.app/api/loan/get-all"),
        headers: _setHeaders(token),
      );
    }
    catch(e){
      print(e.toString());
    }
  }


  addGuaranteeAmount(loanId, memberId, amount) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token')!;
    try {
      return await http.put(
        Uri.parse("https://known-krill-greatly.ngrok-free.app/api/loan/update-amount?memberId=$memberId&loanId=$loanId&amount=$amount"),
        headers: _setHeaders(token),
      );
    }
    catch(e){
      print(e.toString());
    }
  }

  getLoanRepayments(loanId) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token')!;
    try {
      return await http.get(
        Uri.parse("https://known-krill-greatly.ngrok-free.app/api/repayment/loan-repayments/$loanId"),
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