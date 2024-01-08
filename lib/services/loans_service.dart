
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
    List<Loan> loans = [];
    try {
      Response res = await LoansController().getMembersLoans();
      List jsonData = await jsonDecode(res.body.trim());
      if(jsonData != []){
        for (var e in jsonData) {
          Loan loan = Loan();
          loan.id = e['id'];
          loan.principal=e['principal'];
          loan.loanStatus=e['loanStatus'];
          loan.instalments=e['instalments'];
          loan.loanType=e['loanType'];
          loan.amount=e['amount'];
          loan.applicationDate=e['applicationDate'];
          loans.add(loan);
        }
      }
    }
    catch(e){
      if (kDebugMode) {
        print(e.toString());
      }
    }
    return loans;
  }

  Future<List<Loan>?> getAllLoans() async{
    List<Loan> loans = [];
    try {
      Response res = await LoansController().getAllLoans();
      List jsonData = await jsonDecode(res.body.trim());
      if(jsonData != []){
        for (var e in jsonData) {
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
        }
      }
    }
    catch(e){
      if (kDebugMode) {
        print(e.toString());
      }
    }
    return loans;
  }

  Future<List<Member>?> getLoanGuarantors(loanId) async {
    List<Member> guarantors =[];
    try{
      Response res = await LoansController().getLoanGuarantors(loanId);
      Map<String, dynamic> jsonData = await jsonDecode(res.body);
      List guarantorsList = jsonData['guarantors'];
      // print(jsonData);
      for (var e in guarantorsList) {
        Member guarantor = Member();
        guarantor.id = e['id'];
        guarantor.firstName=e['firstName'];
        guarantor.midName=e['midName'];
        guarantor.lastName=e['lastName'];
        guarantors.add(guarantor);
      }

    }
    catch(ex){
      if (kDebugMode) {
        print(ex.toString());
      }
    }
    return guarantors;

  }

  Future<List<LoanGuarantor>?> getGuaranteedAmount(loanId) async {
    List<LoanGuarantor> guarantees = [];
    try{
      Response res = await LoansController().getGuaranteedAmount(loanId);
      List jsonData = await jsonDecode(res.body);
      // print(jsonData);
      for (var e in jsonData) {
        LoanGuarantor lg=LoanGuarantor();
        lg.memberId=e['memberId'];
        lg.firstName=e['firstName'];
        lg.midName=e['midName'];
        lg.amount=e['amount'];
        guarantees.add(lg);
      }
    }
    catch(ex){
      if (kDebugMode) {
        print(ex.toString());
      }
    }
    return guarantees;
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
      for (var e in jsonData) {
        Repayment repayment = Repayment();
        repayment.loanId = e['loanId'];
        repayment.repaymentDate=e['repaymentDate'];
        repayment.amount=e['amount'];
        repayments.add(repayment);
      }
      return repayments;
    }
    catch(e){
      rethrow;
    }
  }

  getTotalGuaranteedAmount(String? guarantorId) async{
    Response res = await LoansController().getTotalGuaranteedAmount(guarantorId);
    var jsonData = jsonDecode(res.body.trim());
    return jsonData;

  }

}