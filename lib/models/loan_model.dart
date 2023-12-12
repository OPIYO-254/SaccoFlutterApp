import 'repayment_model.dart';
import 'member_model.dart';

class Loan{
  int? id;
  String? loanType;
  String? applicationDate;
  double? principal;
  int? instalments;
  double? amount;
  int? interest;
  String? loanStatus;
  int? totalGuaranteed;
  String? memberId;
  String? borrowerFname;
  String? borrowerMname;
  String? borrowerLname;
  List<Repayment>? repayments;
  List<Member>? guarantors;


  Loan({
    this.id,
    this.loanType,
    this.applicationDate,
    this.principal,
    this.instalments,
    this.amount,
    this.interest,
    this.loanStatus,
    this.totalGuaranteed,
    this.memberId,
    this.borrowerFname,
    this.borrowerMname,
    this.borrowerLname,
    this.repayments,
    this.guarantors

  });

  Loan.fromJson(Map<String, dynamic> map){
    id=map['id'];
    loanType=map['loanType'];
    applicationDate=map["applicationDate"];
    principal=map['principal'];
    instalments=map['instalments'];
    amount = map['amount'];
    interest=map['interest'];
    loanStatus=map['loanStatus'];
    totalGuaranteed=map['totalGuaranteed'];
    memberId=map['memberId'];
    borrowerFname=map['borrowerFname'];
    borrowerMname=map['borrowerMname'];
    borrowerLname=map['borrowerLname'];
    if(map['repayment']!=null){
      repayments = <Repayment>[];
      (map['repayment'] as List).forEach((e) {
        repayments!.add(Repayment.fromJson(e));
      });
    };
    if(map['guarantor']!=null){
      guarantors = <Member>[];
      (map['guarantor'] as List).forEach((e) {
        guarantors!.add(Member.fromJson(e));
      });
    }

  }

}