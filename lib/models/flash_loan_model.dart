class FlashLoanModel{
  int? id;
  double? principal;
  String? applicationDate;
  String? repayDate;
  String? loanStatus;
  double? amount;
  String? memberId;

  FlashLoanModel({
    this.id,
    this.principal,
    this.applicationDate,
    this.repayDate,
    this.loanStatus,
    this.amount,
    this.memberId
  });

  FlashLoanModel.fromJson(Map<String, dynamic> map){
    id=map['id'];
    principal=map['principal'];
    applicationDate=map['applicationDate'];
    repayDate=map['repayDate'];
    loanStatus=map['loanStatus'];
    amount=map['amount'];
    // memberId=map['memberId'];
  }
}