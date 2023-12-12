import 'dart:convert';
import 'package:http/http.dart';
import 'package:sojrel_sacco_client/models/contribution_model.dart';

import '../controller/member_controller.dart';
import '../models/flash_loan_model.dart';
import '../models/loan_model.dart';
import '../models/member_model.dart';


class MemberDetails{

  Future<Member> fetchMemberDetails() async {
    Response res = await MemberApi().getMember();
    try {
      Map<String, dynamic> jsonData = await jsonDecode(res.body.trim());
      // print(jsonData);
      if (res.statusCode == 200) {
        Member member = Member();
        member.id = jsonData['member']['id'];
        member.firstName = jsonData["member"]['firstName'];
        member.midName = jsonData['member']['midName'];
        member.lastName = jsonData['member']['lastName'];
        member.email = jsonData['member']['email'];
        member.phone=jsonData['member']['phone'];
        member.totalContributions = jsonData['totalContributions'];
        member.totalShares = jsonData['totalShares'];
        member.totalSavings = jsonData['totalSavings'];
        member.passportUrl = jsonData['passportUrl'];

        List contrib = jsonData['member']['contributions'];
        List<Contribution> contributions = [];
        if (contrib != []) {
          contrib.forEach((e) {
            Contribution contribution = Contribution();
            contribution.id = e['id'];
            contribution.contributionType = e['contributionType'];
            contribution.contributionDate = e['contributionDate'];
            contribution.amount = e['amount'];
            contributions.add(contribution);
          });
        }
        member.contributions = contributions;
        List loans = jsonData['member']['loansTaken'];
        List<Loan> loansList = [];
        if (loans != []) {
          loans.forEach((e) {
            Loan loan = Loan();
            loan.id = e['id'];
            loan.applicationDate = e['applicationDate'];
            loan.principal = e['principal'];
            loan.loanType = e['loanType'];
            loan.instalments = e['instalments'];
            loan.loanStatus = e['loanStatus'];
            loansList.add(loan);
          });
        }
        member.loansTaken = loansList;

        List guaranteed =jsonData['member']['loansGuaranteed'];
        List<Loan> guaranteedList =[];
        if(guaranteed !=[]){
          guaranteed.forEach((e) {
            Loan l = Loan();
            l.id = e['id'];
            l.applicationDate = e['applicationDate'];
            l.principal = e['principal'];
            l.loanType = e['loanType'];
            l.instalments = e['instalments'];
            l.loanStatus = e['loanStatus'];
            l.memberId=e['memberId'];
            l.borrowerFname=e['borrowerFname'];
            l.borrowerMname=e['borrowerMname'];
            l.borrowerLname=e['borrowerLname'];
            guaranteedList.add(l);
          });
        }
        member.loansGuaranteed = guaranteedList;

        List flashLoans = jsonData['member']['flashLoans'];
        List<FlashLoanModel> loanList = [];
        flashLoans.forEach((e) {
          FlashLoanModel loan=FlashLoanModel();
          // print(e['amount']);
          loan.id=e['id'];
          loan.principal=e['principal'];
          loan.applicationDate=e['applicationDate'];
          loan.repayDate=e['repayDate'];
          loan.amount=e['amount'];
          loan.loanStatus=e['loanStatus'];
          loanList.add(loan);
        });
        member.flashLoans = loanList;
        return member;
      } else {
        throw Exception('Failed to load member');
      }
    }
    catch(e){
      rethrow;
    }

  }

}