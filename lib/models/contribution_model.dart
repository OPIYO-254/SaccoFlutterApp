
class Contribution{
  int? id;
  String? contributionDate;
  String? contributionType;
  int? amount;

  Contribution({
    this.id,
    this.contributionDate,
    this.contributionType,
    this.amount,
  });

  Contribution.fromJson(Map<String, dynamic> map){
    id=map['id'];
    contributionDate=map['contributionDate'];
    contributionType=map['contributionType'];
    amount=map['amount'];
  }
}