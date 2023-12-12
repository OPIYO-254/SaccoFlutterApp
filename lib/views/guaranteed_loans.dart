import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sojrel_sacco_client/utils/colors.dart';

import '../components/buttons.dart';
import '../components/divider.dart';
import '../models/loan_model.dart';
import '../models/member_model.dart';
import '../models/repayment_model.dart';
import '../services/loans_service.dart';
import '../services/member_details_service.dart';

class GuaranteedLoans extends StatefulWidget {
  const GuaranteedLoans({super.key});

  @override
  State<GuaranteedLoans> createState() => _GuaranteedLoansState();
}

class _GuaranteedLoansState extends State<GuaranteedLoans> {
  MyColors colors = MyColors();
  List<Loan>? guaranteedLoans;
  List<Repayment>? repayments;

  Future<List<Loan>> fetchGuaranteedLoans() async{
    Member member = await MemberDetails().fetchMemberDetails();
    List<Loan>? guaranteedLoans = member.loansGuaranteed;
    List<Loan>? allLoans = await LoansService().getAllLoans();
    List<Loan> loans=[];
    guaranteedLoans?.forEach((e) {
      allLoans?.forEach((i) {
        if(e.id == i.id){
          if(e.loanStatus != 'REVIEW'){
            loans.add(i);
            // print(e.loanType);
          }
        }
      });

    });
    return loans;
  }

  Future<List<Repayment>?> fetchLoanRepayments(loanId) async{
    List<Repayment>? repayments = await LoansService().getLoanRepayments(loanId);
    return repayments;
  }

  Future<double> calculateTotalAmount(id) async{
    double total = 0.0;
    List<Repayment>? repayments = await LoansService().getLoanRepayments(id);
    repayments?.forEach((e) {
      total += e.amount!;
    });
    // print(total);
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: colors.green,
        title: const Text('Guarantee History'),
      ),
      body: SingleChildScrollView(
        child: Container(
          height:(MediaQuery.of(context).size.height)/1.1,
          // ,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.background,
              borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(24),
                  topLeft: Radius.circular(24)
              )
          ),
          child: Column(
            children: [
              const SizedBox(height: 8.0,),
              // SizedBox(
              //     height: 24,
              //     child: Text('Guaranteed Loans', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: colors.green),)),

              // const SizedBox(height: 8,),
              Expanded(
                  child: FutureBuilder(
                    future: fetchGuaranteedLoans(),
                    builder: (context, snapshot){
                      if(snapshot.hasData){
                        guaranteedLoans = snapshot.data;
                        return ListView.builder(
                          itemCount: guaranteedLoans == null? 0: guaranteedLoans!.length,
                          itemBuilder: (BuildContext context, int index){
                            Loan loan = guaranteedLoans![index];
                            return Container(
                              height: 180,
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4.0),
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      //Text('Guaranteed: Ksh: ')
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text('Loan:'),
                                            Text('#${loan.id} (${loan.loanType})',
                                              style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),),
                                          ],
                                        ),
                                      ),

                                      SizedBox(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            const Text('Application Date:'),
                                            Text(DateFormat.yMMMEd().format(DateTime.parse(loan.applicationDate!)),
                                                style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold))
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
                                            const Text('Loan Applicant:'),
                                            Text(loan.borrowerMname != '' ? "${loan.borrowerFname} ${loan.borrowerMname}" : "${loan.borrowerFname} ${loan.borrowerLname}",
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0),),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            const Text('Amount Applied:'),
                                            Text("Ksh ${loan.principal}",
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0)),
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
                                            const Text('Loan instalments:'),
                                            Text("${loan.instalments} Months",
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0)),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            const Text("Loan Status:"),
                                            Text("${loan.loanStatus}",
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0))
                                          ],
                                        ),
                                      )

                                    ],
                                  ),
                                  MyDivider(),
                                  SizedBox(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        RoundedButton(
                                            color: colors.green,
                                            onTap: ()=>guaranteedLoanDetailsBottomSheet(context, loan.id, loan.amount),
                                            text: 'View Repayment',
                                            width: 150,
                                            height: 36,
                                            borderRadius: BorderRadius.circular(18.0))
                                      ],
                                    ),
                                  )

                                ],
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

            ],
          ),
        ),
      ),
    );
  }

  Future<void> guaranteedLoanDetailsBottomSheet(BuildContext context, loanId, amount) async{
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
              // ,
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
                      child: Text('Repayments for Loan ID #$loanId', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: colors.green),)),
                  SizedBox(
                    child: FutureBuilder<double>(
                      future: calculateTotalAmount(loanId),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Text('Loading...');
                        } else if (snapshot.hasError) {
                          // Navigator.pop(context);
                          return const Text('Error');
                        } else {
                          double total = snapshot.data!;
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              (total != null)?Text('Total Repaid: Ksh ${total}',style:
                          const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)):
                          LinearProgressIndicator(color: colors.green,),
                              Text('Outstanding: Ksh ${amount-total}')
                            ],
                          );

                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 8,),
                  Expanded(
                      child: FutureBuilder(
                        future: fetchLoanRepayments(loanId),
                        builder: (context, snapshot){
                          if(snapshot.hasData){
                            repayments = snapshot.data;
                            return ListView.builder(
                              itemCount: repayments == null? 0: repayments!.length,
                              itemBuilder: (BuildContext context, int index){
                                Repayment repay = repayments![index];
                                return Container(
                                  height: 60,
                                  margin: const EdgeInsets.symmetric(vertical: 4),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4.0),
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          SizedBox(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                const Text('Date:'),
                                                Text(DateFormat.yMMMEd().format(DateTime.parse(repay.repaymentDate!)),
                                                  style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),)
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            height:40,
                                            child: VerticalDivider(
                                              thickness: 2,
                                              width: 2,
                                              color: Theme.of(context).colorScheme.tertiary,
                                            ),
                                          ),
                                          SizedBox(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                const Text('Amount:'),
                                                Text('Ksh ${repay.amount}',
                                                  style: const TextStyle(fontSize: 14.0,fontWeight: FontWeight.bold),),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    ],
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
