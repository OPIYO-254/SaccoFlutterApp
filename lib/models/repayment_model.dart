class Repayment{
  String? repaymentDate;
  int? loanId;
  double? amount;

  Repayment({
    this.repaymentDate,
    this.loanId,
    this.amount
  });

  Repayment.fromJson(Map<String, dynamic> map){
    repaymentDate = map['repaymentDate'];
    loanId = map['loanId'];
    amount=map['amount'];
  }
}
