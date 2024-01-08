import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sojrel_sacco_client/models/contribution_model.dart';
import 'package:sojrel_sacco_client/utils/shared_preferences.dart';
import '../controller/member_controller.dart';
import '../models/flash_loan_model.dart';
import '../models/loan_model.dart';
import '../models/member_model.dart';
import 'package:hive/hive.dart';


class MemberDetails{
  Future<Map<String, dynamic>> fetchMemberData() async {
    MySharedPreferences mySharedPreferences = MySharedPreferences();
    final String? storedData = await mySharedPreferences.getDataIfNotExpired("memberDetails");
    late Map<String, dynamic> jsonData;
    try {
      final result = await InternetAddress.lookup('www.sojrelsacco.com');
      // print(result[0]);
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {//check if device is connected
        // print('connected');
        if (storedData != null) {//check if there is data in cache else fetch it from server and assign it to jsonData
          jsonData = jsonDecode(storedData);
        }
        else{
          Response res = await MemberApi().getMember();
          jsonData = await jsonDecode(res.body.trim());
          // print(jsonData);
          if (res.statusCode == 200) {
            await mySharedPreferences.saveDataWithExpiration('memberDetails',
                res.body, const Duration(minutes: 3));
          }
        }
      }
      else{
        // print('not connected');
        if (storedData != null) {//check if there is data in cache else fetch it from server and assign it to jsonData
          jsonData = jsonDecode(storedData);
        }
        else{
          throw Exception("Not found");
        }
        throw Exception("not found");
      }
      return jsonData;
    } on SocketException catch (_) {
      // print('error! not connected');
      if (storedData != null) {
        jsonData = jsonDecode(storedData);
      }
    }
    return jsonData;

  }


  Future<Member> fetchMemberDetails() async {
    try {
        Map<String, dynamic> jsonData = await fetchMemberData();
        Member member = Member();
        member.id = jsonData['member']['id'];
        member.firstName = jsonData["member"]['firstName'];
        member.midName = jsonData['member']['midName'];
        member.lastName = jsonData['member']['lastName'];
        member.email = jsonData['member']['email'];
        member.phone = jsonData['member']['phone'];
        member.totalContributions = jsonData['totalContributions'];
        member.totalShares = jsonData['totalShares'];
        member.totalSavings = jsonData['totalSavings'];
        List arrayList = jsonData['member']["userFiles"];
        if (arrayList.isNotEmpty) {
          Map<String, dynamic> urlDetails = arrayList[3];
          member.passportUrl = urlDetails['fileUrl'];
        }
        List contrib = jsonData['member']['contributions'];
        List<Contribution> contributions = [];
        if (contrib != []) {
          for (var e in contrib) {
            Contribution contribution = Contribution();
            contribution.id = e['id'];
            contribution.contributionType = e['contributionType'];
            contribution.contributionDate = e['contributionDate'];
            contribution.amount = e['amount'];
            contributions.add(contribution);
          }
        }
        member.contributions = contributions;
        List loans = jsonData['member']['loansTaken'];
        List<Loan> loansList = [];
        if (loans != []) {
          for (var e in loans) {
            Loan loan = Loan();
            loan.id = e['id'];
            loan.applicationDate = e['applicationDate'];
            loan.principal = e['principal'];
            loan.loanType = e['loanType'];
            loan.instalments = e['instalments'];
            loan.loanStatus = e['loanStatus'];
            loansList.add(loan);
          }
        }
        member.loansTaken = loansList;

        List guaranteed = jsonData['member']['loansGuaranteed'];
        List<Loan> guaranteedList = [];
        if (guaranteed != []) {
          for (var e in guaranteed) {
            Loan l = Loan();
            l.id = e['id'];
            l.applicationDate = e['applicationDate'];
            l.principal = e['principal'];
            l.loanType = e['loanType'];
            l.instalments = e['instalments'];
            l.loanStatus = e['loanStatus'];
            l.memberId = e['memberId'];
            l.borrowerFname = e['borrowerFname'];
            l.borrowerMname = e['borrowerMname'];
            l.borrowerLname = e['borrowerLname'];
            guaranteedList.add(l);
          }
        }
        member.loansGuaranteed = guaranteedList;

        List flashLoans = jsonData['member']['flashLoans'];
        List<FlashLoanModel> loanList = [];
        for (var e in flashLoans) {
          FlashLoanModel loan = FlashLoanModel();
          // print(e['amount']);
          loan.id = e['id'];
          loan.principal = e['principal'];
          loan.applicationDate = e['applicationDate'];
          loan.repayDate = e['repayDate'];
          loan.amount = e['amount'];
          loan.loanStatus = e['loanStatus'];
          loan.processingFee=e['processingFee'];
          loanList.add(loan);
        }
        member.flashLoans = loanList;
        return member;
      }
      catch (e) {
        rethrow;
      }
  }

  // Future<String?>? getPhotoUrl() async{
  //   Response res = await MemberApi().getPhotoUrl();
  //   String? url;
  //   try {
  //     Map<String, dynamic> jsonData = await jsonDecode(res.body.trim());
  //     // print(jsonData);
  //     url = jsonData['fileUrl'];
  //   }
  //     catch(e){
  //       if (kDebugMode) {
  //         print(e.toString());
  //       }
  //     }
  //     return url;
  //
  }

