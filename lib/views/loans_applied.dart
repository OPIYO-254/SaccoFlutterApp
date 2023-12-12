import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sojrel_sacco_client/components/buttons.dart';
import 'package:sojrel_sacco_client/components/divider.dart';
import 'package:sojrel_sacco_client/services/loans_service.dart';
import 'package:sojrel_sacco_client/utils/colors.dart';

import '../models/guarantor_model.dart';
import '../models/loan_model.dart';
import '../models/member_model.dart';
import '../services/members_service.dart';
import 'add_guarantors.dart';

class GuaranteeLoan extends StatefulWidget {
  const GuaranteeLoan({super.key});

  @override
  State<GuaranteeLoan> createState() => _GuaranteeLoanState();
}

class _GuaranteeLoanState extends State<GuaranteeLoan> {
  late SharedPreferences prefs;
  MyColors colors = MyColors();
  List<Loan>? appliedLoans;
  List<Member>? guarantorList;
  List<LoanGuarantor>? guarantee;
  List<Loan>? loans;
  Loan? loan;
  int? id;
  String? date;
  String? type;
  double? applied;
  double? guaranteed;
  double? repayable;


  Future<List<Member>?> getAllMembers() async {
    List<Member>? member = await MemberService().fetchMembers();
    return member;
  }

  Future<List<Loan>?> getAppliedLoans() async {
    loans = await LoansService().fetchMembersLoans();
    // Member member = await MemberDetails().fetchMemberDetails();
    prefs = await SharedPreferences.getInstance();
    // loans = member.loansTaken;
    List<Loan> appliedLoans = [];
    loans?.forEach((e) {
      if(e.loanStatus == 'REVIEW'){
        // print(e);
        appliedLoans.add(e);
      }
    });
    return appliedLoans;
  }

  Future<Loan?> loanDetails(id) async {
    loan = await LoansService().getLoanDetails(id);
    // print(loan?.principal);
    return loan;
  }

  Future<List<LoanGuarantor>?> getGuaranteedAmount(loanId) async{
    guarantee = await LoansService().getGuaranteedAmount(loanId);
    return guarantee;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAppliedLoans();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Loans Applied'), backgroundColor: colors.green, elevation: 0,),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SingleChildScrollView(
        child: Container(
          height:(MediaQuery.of(context).size.height)/1.1,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            children: [
              const SizedBox(height: 18,),
              SizedBox(
                  height: 36,
                  child: Text('Select loan to add guarantors', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: colors.green),)),
              Expanded(
                child: FutureBuilder(
                    future: getAppliedLoans(),
                    builder: (context, snapshot) {
                      if(snapshot.hasData){
                        appliedLoans = snapshot.data;
                        return ListView.builder(
                            // scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            itemCount: appliedLoans == null? 0: appliedLoans?.length,
                            itemBuilder: (BuildContext context, int index){
                              Loan? loans = appliedLoans?[index];
                              return Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    margin: EdgeInsets.symmetric(horizontal: 4),
                                    height: 200,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.primary,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,

                                          children: [
                                            SizedBox(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  const Text('Loan:'),
                                                  Text('#${loans!.id}', style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),),
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                children: [
                                                  const Text('Application Date:'),
                                                  Text(DateFormat.yMMMEd().format(DateTime.parse(loans.applicationDate!)),
                                                      style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold)),
                                                ],
                                              ),
                                            )

                                          ],
                                        ),
                                        MyDivider(),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            SizedBox(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  const Text('Loan Type:'),
                                                  Text('${loans.loanType}', style: const TextStyle(fontSize: 14.0,fontWeight: FontWeight.bold),),
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                children: [
                                                  Text("Instalments:"),
                                                  Text('${loans.instalments} Months',style: const TextStyle(fontSize: 14.0,fontWeight: FontWeight.bold)),
                                                ],
                                              ),
                                            )

                                          ],
                                        ),
                                        MyDivider(),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            SizedBox(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  const Text('Applied Amount:'),
                                                  Text('Ksh ${loans.principal}', style: const TextStyle(fontSize: 14.0,fontWeight: FontWeight.bold),),
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                children: [
                                                  const Text('Repayable Amount:'),
                                                  Text('Ksh ${loans.amount}',style: const TextStyle(fontSize: 14.0,fontWeight: FontWeight.bold))
                                                ],
                                              ),
                                            )

                                        ],
                                        ),
                                        MyDivider(),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            SizedBox(

                                                child: RoundedButton(width: 100,color:colors.green, borderRadius:BorderRadius.circular(24), text: "Add", onTap: ()=>{
                                                  prefs.setInt('loanId', loans.id!),
                                                  Navigator.push(context, MaterialPageRoute(builder: (context)=>const AddGuarantors()))
                                                }, height: 36,)),
                                            const SizedBox(width: 12,),
                                            SizedBox(
                                                child: RoundedButton(width: 100, color:colors.green, height: 36, borderRadius:BorderRadius.circular(24), text: "View", onTap: ()=>{
                                                  loansGuarantorsBottomSheet(context,loans.id!)
                                                },)
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 12,),
                                ],
                              );
                            });
                      }
                      return Center(
                        child: SizedBox(
                            width: 46,
                            height: 46,
                            child: CircularProgressIndicator(color: colors.green,)),
                      );
                    }
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }



  Future<dynamic> loansGuarantorsBottomSheet(BuildContext context, loanId) {//to add loan_id as arg
    return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        isDismissible: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10)
          ),

        ),
        builder: (context){
          return SingleChildScrollView(
            child: Container(
              height:(MediaQuery.of(context).size.height)/1.1,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.background,
                  borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(10),
                      topLeft: Radius.circular(10)
                  )
              ),
              child: Column(
                children: [
                  const SizedBox(height: 24,),
                  SizedBox(
                      height: 36,
                      child: Text('Guarantors for Loan ID #$loanId', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: colors.green),)),
                  FutureBuilder<Loan?>(
                    future: loanDetails(loanId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Text('Loading...');
                      } else if (snapshot.hasError) {
                        // Navigator.pop(context);
                        return const Text('error');
                      } else {
                        Loan loan = snapshot.data!;
                        // ... (Update other properties as needed)
                        return Container(
                          height: 120,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(8)
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('#${loan.id} (${loan.loanType})'),
                                  Text(DateFormat('dd MMM yyyy').format(DateTime.parse(loan.applicationDate!)))
                                  // Text(DateFormat('dd MMM yyyy').format(DateTime.parse(contributions!.contributionDate!)))
                                ],
                              ),
                              MyDivider(),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Applied:'),
                                      Text('Ksh ${loan.principal}',style: const TextStyle(fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  const SizedBox(height: 12,),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Repayable:'),
                                      Text('Ksh ${loan.amount}',style: const TextStyle(fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  const SizedBox(height: 12,),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Total Guaranteed:'),
                                      Text(loan.totalGuaranteed!=null?'Ksh ${loan.totalGuaranteed}':'Ksh 00.0',style: const TextStyle(fontWeight: FontWeight.bold)),
                                    ],
                                  ),

                                ],
                              ),
                            ],
                          ),
                        );
                      }
                    },
                  ),

                  const SizedBox(height: 8,),
                  Expanded(
                      child: FutureBuilder(
                        future: getGuaranteedAmount(loanId),
                        builder: (context, snapshot){
                          if(snapshot.hasData){
                            guarantee = snapshot.data;
                            return ListView.builder(
                              itemCount: guarantee == null? 0: guarantee!.length,
                              itemBuilder: (BuildContext context, int index){
                                LoanGuarantor guarantor = guarantee![index];
                                return Container(
                                  height: 48,
                                  margin: const EdgeInsets.symmetric(vertical: 4),
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4.0),
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Text('${guarantor!.memberId}', style: const TextStyle(fontWeight: FontWeight.bold),),
                                            const SizedBox(width: 4,),
                                            Text(guarantor.midName != '' ? '${guarantor.firstName} ${guarantor.midName}':'${guarantor.firstName}',),
                                          ],
                                        ),
                                        Text(guarantor.amount!=null?'Ksh. ${guarantor.amount}':'Ksh 00.0')
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          }
                          return Center(
                              child: SizedBox(
                                  width: 46,
                                  height: 46,
                                  child: CircularProgressIndicator(color: colors.green,)));
                        },
                      )
                  ),
                  // SizedBox(
                  //   height: 48,
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.center,
                  //     children: [
                  //       IconButton(onPressed: ()=> Navigator.pop(context), icon: Icon(Icons.close_rounded, color: Theme.of(context).colorScheme.tertiary,size: 36,))
                  //     ],
                  //   ),
                  // )
                ],
              ),
            ),
          );
        }
    );
  }


}
