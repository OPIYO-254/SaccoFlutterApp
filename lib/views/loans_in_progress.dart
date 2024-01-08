import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:sojrel_sacco_client/components/buttons.dart';
import 'package:sojrel_sacco_client/models/repayment_model.dart';
import 'package:sojrel_sacco_client/utils/formetter.dart';

import '../components/divider.dart';
import '../components/textfields.dart';
import '../models/loan_model.dart';
import '../models/member_model.dart';
import '../services/loans_service.dart';
import '../services/member_details_service.dart';
import '../theme/dark_theme.dart';

class LoansInProgress extends StatefulWidget {
  const LoansInProgress({super.key});

  @override
  State<LoansInProgress> createState() => _LoansInProgressState();
}

class _LoansInProgressState extends State<LoansInProgress> {
  List<Loan>? loansTaken;
  List<Repayment>? repayments;
  final _searchTextController = TextEditingController();

  Future<List<Loan>?> fetchLoansTaken(String value) async{
    Member member = await MemberDetails().fetchMemberDetails();
    List<Loan>? takenLoans = member.loansTaken;
    List<Loan>? allLoans = await LoansService().getAllLoans();
    List<Loan> loans = [];
    takenLoans?.forEach((element) {
      allLoans?.forEach((e) {
        if(element.id == e.id){
          if(element.loanStatus == 'APPROVED' || element.loanStatus == 'COMPLETED'){
            loans.add(e);
          }
        }
      });
    });
    List<Loan>? results = [];
    if(value.isEmpty){
      results = loans;
    }
    else{
      results = loans.where((e){
        if(e.loanType!.toLowerCase().contains(value.toLowerCase())){
          return e.loanType!.toLowerCase().contains(value.toLowerCase());//search by type
        }
        else if(e.loanStatus!.toLowerCase().contains(value.toLowerCase())){
          return e.loanStatus!.toLowerCase().contains(value.toLowerCase());
        }
        else if(e.id.toString().toLowerCase().contains(value.toLowerCase())){
          return e.id.toString().toLowerCase().contains(value.toLowerCase());
        }
        else{
          return DateFormat('dd MMM yyyy')
              .format(DateTime.parse(e.applicationDate!)).toLowerCase().contains(value.toLowerCase());
        }
      }).toList();
    }
    return results;
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
        title: const Text('Loan History'),
      ),
      body: SingleChildScrollView(
        child: Container(
          height:(MediaQuery.of(context).size.height)/1.2,
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
              // const SizedBox(height: 12,),
              // SizedBox(
              //     height: 36,
              //     child: Text('Loans Taken', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: colors.green),)),
              // const SizedBox(height: 8,),
              const SizedBox(height: 8,),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: MySearchTextField(
                    fieldController: _searchTextController,
                    validatorText: 'Enter value to search',
                    hintText: 'Search',
                    iconColor: Theme.of(context).colorScheme.secondary,
                    suffixIcon: const Icon(Icons.search),
                    onChanged: (searchValue)=>fetchLoansTaken(searchValue)),
              ),
              const SizedBox(height: 8.0),
              Expanded(
                  child: FutureBuilder(
                    future: fetchLoansTaken(_searchTextController.text),
                    builder: (context, snapshot){
                      if(snapshot.hasData){
                        loansTaken = snapshot.data;
                        if(loansTaken!.isEmpty){
                          return const Center(child: Text("No Data"),);
                        }
                        return LiquidPullToRefresh(
                          onRefresh: ()=>fetchLoansTaken(_searchTextController.text),
                          showChildOpacityTransition: false,
                          backgroundColor: colors.green,
                          color: Colors.transparent,
                          height: 80,
                          child: ListView.builder(
                            itemCount: loansTaken == null? 0: loansTaken!.length,
                            itemBuilder: (BuildContext context, int index){
                              Loan loan = loansTaken![index];
                              return Container(
                                height: 200,
                                // width: MediaQuery.of(context).size.width,
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
                                            children: [
                                              const Text('Loan:'),
                                              Text('#${loan.id} (${Formatter().formatAsTitle(loan.loanType!)})',
                                                style: const TextStyle(fontSize: 14.0,fontWeight: FontWeight.bold),),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              const Text('Application Date:'),
                                              Text('Date: ${DateFormat("dd MMM yyy").format(DateTime.parse(loan.applicationDate!))}',
                                                style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),)
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
                                              const Text('Instalments:'),
                                              Text('${loan.instalments} Months',style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold)),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              const Text('Amount Applied:'),
                                              Text('Ksh ${NumberFormat("#,###").format(loan.principal!)}',style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold))
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
                                              const Text('Amount Repayable:'),
                                              Text('Ksh ${NumberFormat("#,###").format(loan.amount)}',style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold)),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              const Text("Status"),
                                              Text(Formatter().formatAsTitle(loan.loanStatus!),style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold))
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
                                              onTap: ()=>loanRepaymentBottomSheet(context, loan.id, loan.amount),
                                              text: 'Repayments',
                                              width: 120,
                                              height: 36,
                                              borderRadius: BorderRadius.circular(18.0))
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              );
                            },
                          ),
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
      )
    );
  }

  Future<void> loanRepaymentBottomSheet(BuildContext context, loanId, amount) async{
    return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        isDismissible: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24)
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
                      child: Text('Repayments for Loan ID #$loanId', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: colors.green),)),
                  // const SizedBox(height: 8,),
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
                                              children: [
                                                const Text('Date:'),
                                                Text(DateFormat.yMMMEd().format(DateTime.parse(repay.repaymentDate!)),
                                                  style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),)
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
                                              children: [
                                                const Text('Amount:'),
                                                Text('Ksh ${repay.amount}',
                                                  style: const TextStyle(fontSize: 18.0,fontWeight: FontWeight.bold),),
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
