class FlashLoanModel{
  int? id;
  double? principal;
  String? applicationDate;
  String? repayDate;
  String? loanStatus;
  double? amount;
  String? memberId;
  double? amountPaid;
  double? processingFee;
  bool? repaidInTime;

  FlashLoanModel({
    this.id,
    this.principal,
    this.applicationDate,
    this.repayDate,
    this.loanStatus,
    this.amount,
    this.memberId,
    this.amountPaid,
    this.processingFee,
    this.repaidInTime
  });

  FlashLoanModel.fromJson(Map<String, dynamic> map){
    id=map['id'];
    principal=map['principal'];
    applicationDate=map['applicationDate'];
    repayDate=map['repayDate'];
    loanStatus=map['loanStatus'];
    amount=map['amount'];
    amountPaid=map['totalRepaid'];
    processingFee=map['processingFee'];
    repaidInTime=map['repaidInTime'];
    // memberId=map['memberId'];
  }
}