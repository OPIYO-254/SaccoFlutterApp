
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:sojrel_sacco_client/models/member_model.dart';
import 'package:sojrel_sacco_client/models/repayment_model.dart';

import '../controller/loans_controller.dart';
import '../models/guarantor_model.dart';
import '../models/loan_model.dart';

class LoansService{
  Future<List<Loan>?> fetchMembersLoans() async{
    try {
      Response res = await LoansController().getMembersLoans();
      List jsonData = await jsonDecode(res.body.trim());
      List<Loan> loans = [];
      if(jsonData != []){
        jsonData.forEach((e) {
          Loan loan = Loan();
          loan.id = e['id'];
          loan.principal=e['principal'];
          loan.loanStatus=e['loanStatus'];
          loan.instalments=e['instalments'];
          loan.loanType=e['loanType'];
          loan.amount=e['amount'];
          loan.applicationDate=e['applicationDate'];
          loans.add(loan);
        });
      }
      return loans;
    }
    catch(e){
      print(e.toString());
    }
  }

  Future<List<Loan>?> getAllLoans() async{

    try {
      Response res = await LoansController().getAllLoans();
      List jsonData = await jsonDecode(res.body.trim());
      List<Loan> loans = [];
      if(jsonData != []){
        jsonData.forEach((e) {
          Loan loan = Loan();
          loan.id = e['id'];
          loan.principal=e['principal'];
          loan.loanStatus=e['loanStatus'];
          loan.instalments=e['instalments'];
          loan.loanType=e['loanType'];
          loan.amount=e['amount'];
          loan.applicationDate=e['applicationDate'];
          loan.memberId=e['memberId'];
          loan.borrowerFname=e['borrowerFname'];
          loan.borrowerMname=e['borrowerMname'];
          loan.borrowerLname=e['borrowerLname'];
          loans.add(loan);
        });
      }
      return loans;
    }
    catch(e){
      print(e.toString());
    }
  }

  Future<List<Member>?> getLoanGuarantors(loanId) async {
    try{
      Response res = await LoansController().getLoanGuarantors(loanId);
      Map<String, dynamic> jsonData = await jsonDecode(res.body);
      List guarantorsList = jsonData['guarantors'];
      print(jsonData);
      List<Member> guarantors =[];
      if(guarantorsList!=null){
        guarantorsList.forEach((e){
          Member guarantor = Member();
          guarantor.id = e['id'];
          guarantor.firstName=e['firstName'];
          guarantor.midName=e['midName'];
          guarantor.lastName=e['lastName'];
          guarantors.add(guarantor);
        });
      }
      return guarantors;
    }
    catch(ex){
      print(ex.toString());
    }

  }

  Future<List<LoanGuarantor>?> getGuaranteedAmount(loanId) async {
    try{
      Response res = await LoansController().getGuaranteedAmount(loanId);
      List jsonData = await jsonDecode(res.body);
      // print(jsonData);
      List<LoanGuarantor> guarantees = [];
      if(jsonData!=null){
        jsonData.forEach((e) {
          LoanGuarantor lg=LoanGuarantor();
          lg.memberId=e['memberId'];
          lg.firstName=e['firstName'];
          lg.midName=e['midName'];
          lg.amount=e['amount'];
          guarantees.add(lg);
        });
      }
      return guarantees;
    }
    catch(ex){
      print(ex.toString());
    }
  }

  Future<Loan> getLoanDetails(loanId) async {
    try{
      Response res = await LoansController().getLoanDetails(loanId);
      var jsonData = jsonDecode(res.body.trim());
      // print(jsonData);
      Loan loan = Loan();
      loan.id = jsonData['dto']['id'];
      loan.applicationDate=jsonData['dto']['applicationDate'];
      loan.loanType=jsonData['dto']['loanType'];
      loan.principal=jsonData['dto']['principal'];
      loan.instalments=jsonData['dto']['instalments'];
      loan.amount=jsonData['dto']['amount'];
      loan.totalGuaranteed=jsonData['totalGuaranteed'];
      return loan;
    }
    catch(e){
      throw e;
    }
  }

  Future<List<Repayment>?> getLoanRepayments(loanId) async{
    try{
      Response res = await LoansController().getLoanRepayments(loanId);
      List jsonData = jsonDecode(res.body.trim());
      // print(jsonData);
      List<Repayment> repayments =[];
      if(jsonData != null){
        jsonData.forEach((e) {
          Repayment repayment = Repayment();
          repayment.loanId = e['loanId'];
          repayment.repaymentDate=e['repaymentDate'];
          repayment.amount=e['amount'];
          repayments.add(repayment);
        });
      }
      return repayments;
    }
    catch(e){
      throw e;
    }
  }

}