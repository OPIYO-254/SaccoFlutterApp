import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class LoansController{
  // final String _url = 'https://sojrelsacco.com/api';
  final String _url = "https://known-krill-greatly.ngrok-free.app/api";
  late final String token;
  late final String id;
  postLoan(data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token')!;
    String apiUrl="/loan/add";
    String fullUrl=_url+apiUrl;
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

  getMembersLoans() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    id = prefs.getString("id")!;
    token = prefs.getString('token')!;
    String apiUrl="/loan/get-loans/$id";
    String fullUrl=_url+apiUrl;
    try {
      return await http.get(
        Uri.parse(fullUrl),
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
    String apiUrl="/loan/add-guarantor/$loanId/$guarantorId";
    String fullUrl=_url+apiUrl;
    try {
      return await http.post(
        Uri.parse(fullUrl),
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
    String apiUrl="/loan/get-one/$loanId";
    String fullUrl=_url+apiUrl;
    try {
      return await http.get(
        Uri.parse(fullUrl),
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
    String apiUrl="/loan/get-guarantors/$loanId";
    String fullUrl=_url+apiUrl;
    try {
      return await http.get(
        Uri.parse(fullUrl),
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
    String apiUrl="/loan/loan-details/$loanId";
    String fullUrl=_url+apiUrl;
    try {
      return await http.get(
        // Uri.parse("http://10.0.2.2:8080/api/loan/loan-details/$loanId"),
        Uri.parse(fullUrl),
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
    String apiUrl="/loan/get-all";
    String fullUrl=_url+apiUrl;
    try {
      return await http.get(
        // Uri.parse("http://10.0.2.2:8080/api/loan/get-all"),
        Uri.parse(fullUrl),
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
    String apiUrl="/loan/update-amount?memberId=$memberId&loanId=$loanId&amount=$amount";
    String fullUrl=_url+apiUrl;
    try {
      return await http.put(
        Uri.parse(fullUrl),
        headers: _setHeaders(token),
      );
    }
    catch(e){
      print(e.toString());
    }
  }

  getTotalGuaranteedAmount(memberId) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token')!;
    String apiUrl="/loan/guarantee-total?memberId=$memberId";
    String fullUrl=_url+apiUrl;
    try {
      return await http.get(
        Uri.parse(fullUrl),
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
    String apiUrl="/repayment/loan-repayments/$loanId";
    String fullUrl=_url+apiUrl;
    try {
      return await http.get(
        Uri.parse(fullUrl),
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