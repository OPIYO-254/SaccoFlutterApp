
class LoanGuarantor{
  String? memberId;
  int? loanId;
  String? firstName;
  String? midName;
  double? amount;
  String? phone;
  String? email;

  LoanGuarantor({
    this.memberId,
    this.loanId,
    this.firstName,
    this.midName,
    this.email,
    this.phone,
    this.amount,
  });

  LoanGuarantor.fromJson(Map<String, dynamic> map){
    memberId=map['id'];
    loanId=map['contributionDate'];
    firstName=map['contributionType'];
    midName=map['midName'];
    email=map['email'];
    phone=map['phone'];
    amount=map['amount'];
  }
}