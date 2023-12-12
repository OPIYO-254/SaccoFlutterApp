// class Members{
//   List<Member>? members;
//   Members({this.members});
//   Members.fromJson(Map<String, dynamic> json){
//     if(json['member']!=null){
//       members = <Member>[];
//       (json['member'] as List).forEach((e) {
//         members!.add(Member.fromJson(e));
//       });
//     };
//   }
// }

import 'package:sojrel_sacco_client/models/flash_loan_model.dart';

import 'contribution_model.dart';
import 'loan_model.dart';
import 'repayment_model.dart';

class Member{
  // {"member":{"contributions":[{"id":1,"contributionDate":"2023-10-31T22:28:50.782327","contributionType":"SHARES","amount":10000},{"id":2,"contributionDate":"2023-10-31T22:29:33.645434","contributionType":"SAVINGS","amount":5000}],"loansTaken":[],"loansGuaranteed":[]},"totalSavings":5000,"totalShares":10000,"totalContributions":15000,"passportUrl":"http://localhost:8080/api/files/show/SJS001_photo.jpeg"}
  String? id;
  List<Contribution>? contributions;
  List<Loan>? loansTaken;
  List<Loan>? loansGuaranteed;
  List<FlashLoanModel>? flashLoans;
  String? firstName;
  String? midName;
  String? lastName;
  String? regDate;
  int? idNo;
  String? dob;
  String? email;
  String? phone;
  String? alternativePhone;
  String? kraPin;
  String? gender;
  String? residence;
  String? address;
  String? passportUrl;
  int? totalSavings;
  int? totalShares;
  int? totalContributions;


  Member({
    this.id,
    this.contributions,
    this.loansTaken,
    this.loansGuaranteed,
    this.flashLoans,
    this.firstName,
    this.midName,
    this.lastName,
    this.regDate,
    this.idNo,
    this.dob,
    this.email,
    this.phone,
    this.alternativePhone,
    this.kraPin,
    this.gender,
    this.residence,
    this.address,
    this.totalSavings,
    this.totalShares,
    this.totalContributions
  });
   Member.fromJson(Map<String, dynamic> json){
        id= json['id'];
        // contributions: map['contributions'],
        if(json['contributions']!=null){
          contributions = <Contribution>[];
          (json['contributions'] as List).forEach((e) {
            contributions!.add(Contribution.fromJson(e));
          });
        };

        if(json['loans_applied']!=null){
          loansTaken = <Loan>[];
          (json['loanTaken'] as List).forEach((e) {
            loansTaken!.add(Loan.fromJson(e));
          });
        };

        if(json['loans_guaranteed']!=null){
          loansGuaranteed = <Loan>[];
          (json['loans_guaranteed'] as List).forEach((e) {
            loansGuaranteed!.add(Loan.fromJson(e));
          });
        };

        if(json['flashLoans']!=null){
          flashLoans = <FlashLoanModel>[];
          (json['flashLoans'] as List).forEach((e) {
            flashLoans!.add(FlashLoanModel.fromJson(e));
          });
        };

        firstName= json['firstName'];
        midName=json['midName'];
        lastName=json['lastName'];
        regDate=json['regDate'];
        idNo=json['idNo'];
        dob=json['dob'];
        email=json['email'];
        phone=json['phone'];
        alternativePhone=json['alternativePhone'];
        kraPin=json['kraPin'];
        gender=json['gender'];
        residence=json['residence'];
        address=json['address'];
        totalSavings=json['totalSavings'];
        totalShares=json['totalShares'];
        totalContributions=json['totalContributions'];
  }



}




// class LoansGuaranteed{
//   int? id;
//   String? amount;
//   int? member;
//   int? loan;
//
//   LoansGuaranteed({
//     this.id,
//     this.amount,
//     this.member,
//     this.loan
//   });

  // LoansGuaranteed.fromJson(Map<String, dynamic> map){
  //       id=map['id'];
  //       // total_guarantee: map['total_guarantee'],
  //       if(map['total_guarantee']!=null){
  //         total_guarantee = <TotalGuaranteed>[];
  //         (map['total_guarantee'] as List).forEach((e) {
  //           total_guarantee!.add(TotalGuaranteed.fromJson(e));
  //         });
  //       };
  //       amount=map['amount'];
  //       member=map['member'];
  //       loan=map['loan'];
  // }

// }

// class Guarantor{
//   int? id;
//   List<TotalGuaranteed>? total_guarantee;
//   String? amount;
//   int? member;
//   int? loan;
//
//   Guarantor({
//     this.id,
//     this.total_guarantee,
//     this.amount,
//     this.member,
//     this.loan
//   });
//
//   Guarantor.fromJson(Map<String, dynamic> map){
//     id=map['id'];
//     // total_guarantee: map['total_guarantee'],
//     if(map['total_guarantee']!=null){
//       total_guarantee = <TotalGuaranteed>[];
//       (map['total_guarantee'] as List).forEach((e) {
//         total_guarantee!.add(TotalGuaranteed.fromJson(e));
//       });
//     };
//     amount=map['amount'];
//     member=map['member'];
//     loan=map['loan'];
//   }
//
// }
//
//
//
// class TotalGuaranteed{
//   int loan;
//   double t_amount;
//
//   TotalGuaranteed({required this.loan, required this.t_amount});
//
//   static TotalGuaranteed fromJson(Map<String, dynamic> map){
//     return TotalGuaranteed(loan: map['loan'], t_amount: map['t_amount']);
//   }
// }



