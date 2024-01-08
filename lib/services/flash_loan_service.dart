
import 'dart:convert';

import 'package:fluttertoast/fluttertoast.dart';
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
      for (var e in jsonData) {
        FlashLoanModel loan=FlashLoanModel();
        loan.id=e['id'];
        loan.principal=e['principal'];
        loan.applicationDate=e['applicationDate'];
        loan.repayDate=e['repayDate'];
        loan.amount=e['amount'];
        loan.processingFee=e['processingFee'];
        loan.loanStatus=e['loanStatus'];
        List repayments = e['repayments'];
        double totalAmount = repayments.fold(
            0, (previousValue, transaction) => previousValue + transaction['amount']);
        loan.amountPaid = totalAmount;
        loan.repaidInTime=e['repaidInTime'];
        loanList.add(loan);
      }
      loanList.sort((a, b) =>
          DateTime.parse(b.applicationDate!).compareTo(DateTime.parse(a.applicationDate!))); //order from latest to oldest
      return loanList;
    }
    catch (e){
      print(e.toString());
    }
    return null;
  }

  Future<FlashLoanModel?> getLoanAndTotal (loanId) async{
    try {
      Response res = await FlashLoanController().getLoanTotalRepaidAmount(loanId);
      var jsonData = jsonDecode(res.body.trim());
      // print(jsonData);
      FlashLoanModel loan=FlashLoanModel();
      if(jsonData!=null){
        loan.id=jsonData['loan']['id'];
        loan.principal=jsonData['loan']['principal'];
        loan.applicationDate=jsonData['loan']['applicationDate'];
        loan.repayDate=jsonData['loan']['repayDate'];
        loan.amount=jsonData['loan']['amount'];
        loan.processingFee=jsonData['loan']['processingFee'];
        loan.loanStatus=jsonData['loan']['loanStatus'];
        loan.amountPaid=jsonData['totalRepaid'];
      }
      return loan;
    }
    catch(e){
      print(e.toString());
    }
    return null;
  }

  Future<double?> getLoanLimit() async{
    late double jsonData = 0.0;
    try{
      Response res = await FlashLoanController().getLoanLimit();
      jsonData = jsonDecode(res.body.trim());
    }
    catch (e){
      throw Exception("limit not found");
    }
    return jsonData;
  }
}