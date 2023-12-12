
import 'dart:convert';

import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sojrel_sacco_client/controller/flash_loan_controller.dart';

import '../models/flash_loan_model.dart';

class FlashLoanService{
  Future<List<FlashLoanModel>?> getMemberLoans() async{
    try{
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String memberId = prefs.getString('id')!;

      Response res = await FlashLoanController().getAppliedLoans(memberId);
      List jsonData = jsonDecode(res.body.trim());
      // print(jsonData);
      List<FlashLoanModel> loanList = [];
      jsonData.forEach((e) {
        FlashLoanModel loan=FlashLoanModel();
        loan.id=e['id'];
        loan.principal=e['principal'];
        loan.applicationDate=e['applicationDate'];
        loan.repayDate=e['repayDate'];
        loan.amount=e['amount'];
        loan.loanStatus=e['loanStatus'];
        loanList.add(loan);
      });
      // print(jsonData);
      return loanList;
    }
    catch (e){
      print(e.toString());
    }
  }
}