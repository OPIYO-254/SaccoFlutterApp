import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sojrel_sacco_client/components/buttons.dart';
import 'package:sojrel_sacco_client/components/divider.dart';
import 'package:sojrel_sacco_client/components/textfields.dart';
import 'package:sojrel_sacco_client/components/toast.dart';
import 'package:sojrel_sacco_client/controller/flash_loan_controller.dart';
import 'package:sojrel_sacco_client/services/flash_loan_service.dart';
import 'package:sojrel_sacco_client/services/member_details_service.dart';
import 'package:sojrel_sacco_client/services/members_service.dart';
import 'package:sojrel_sacco_client/utils/colors.dart';

import '../models/flash_loan_model.dart';
import '../models/member_model.dart';
import '../utils/formetter.dart';
import 'flash_loan_application.dart';
import 'flash_payment.dart';


class FlashLoan extends StatefulWidget {
  const FlashLoan({super.key});

  @override
  State<FlashLoan> createState() => _FlashLoanState();
}

class _FlashLoanState extends State<FlashLoan> {
  MyColors colors = MyColors();
  final TextEditingController _amountController = TextEditingController();
  bool? _hasLoan;
  double _sliderValue = 0.0;
  FlashLoanModel? loan;
  DateTime _selectedDate = DateTime.now();
  bool isChecked = false;
  bool isPartial = false;
  String? _name;
  double? loanLimit;
  List<FlashLoanModel>? loanList;
  Future<Member>? _fetchMemberDetails() async {
    try {
      Member fetchedMember = await MemberDetails().fetchMemberDetails();
      _name = fetchedMember.firstName;
      // print(_name);
      return fetchedMember;
    }
    on FormatException catch (e) {
      // log(e.toString());
      throw e;
    }
    on Null catch (e){
      log(e.toString());
      rethrow;
    }
    catch (e) {
      rethrow; // Re-throw the exception to be caught by the FutureBuilder
    }
  }
  void _showDatePicker(){
    showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 180)),
      builder: (context, child) {
        return Theme(
          data: ThemeData().copyWith(
            canvasColor: Theme.of(context).colorScheme.background,
            colorScheme: ColorScheme.light(
              primary: colors.green,
              onPrimary: colors.white,
            ),
          ),
          child: child!,
        );
      },
    ).then((value) {
      setState(() {
        if(value!=null){
        _selectedDate=value!;}
      });
    });

  }




  Future<List<FlashLoanModel>?> getMemberUnpaidLoans() async{
    // Member member =
    List<FlashLoanModel>? loans = await FlashLoanService().getMemberLoans();
    List<FlashLoanModel> flashLoans=[];
    for (var e in loans!) {
      if(e.loanStatus == 'REVIEWING' || e.loanStatus == 'APPROVED'){
        flashLoans.add(e);
      }
    }
    return flashLoans;
  }


  Future<bool> checkMemberLoans() async{
    bool? hasLoan;
    List<FlashLoanModel>? list = await getMemberUnpaidLoans();
    if(list!.isEmpty){
      hasLoan = false;
    }
    else{
      hasLoan = true;
    }
    return hasLoan;

  }

  Future<List<FlashLoanModel>> getMemberLoansHistory() async{
    List<FlashLoanModel>? loans = await FlashLoanService().getMemberLoans();
    List<FlashLoanModel> flashLoans=[];
    if(loans!.isNotEmpty){
      for (var e in loans) {
        if(e.loanStatus == 'PAID'){
          // print(e.processingFee);
          flashLoans.add(e);
        }
      }
    }
    return flashLoans;
  }


  Future<FlashLoanModel?> unpaidLoanDetails() async{
    List<FlashLoanModel>? list = await getMemberUnpaidLoans();
    FlashLoanModel? loanModel;
    if(list!.isNotEmpty){
      loanModel = list.elementAt(0);
    }
    // print(loanModel?.id);

    //
    return loanModel;
  }
  double balance=0.0;
  Future<double> getLoanBalance() async{
    try {
      FlashLoanModel? totalModel = await unpaidLoanDetails();
      double? total = totalModel!.amount! + totalModel.processingFee!;
      FlashLoanModel? loan = await FlashLoanService().getLoanAndTotal(
          totalModel.id);
      double? paid = loan?.amountPaid;
      if (total > 0.0) {
        if (paid != null) {
          balance = total - paid;
        }
        else {
          balance = total;
        }
      }
    }
    catch(e){
      print(e.toString());
    }
    return balance;
  }
  Future<String?> getLoanStatus() async{
    String? status;
    FlashLoanModel? loanModel = await unpaidLoanDetails();
    status = loanModel?.loanStatus;
    return status;
  }

  Future<double?> getLoanLimit() async {
    double? limit = await FlashLoanService().getLoanLimit();
    return limit;
  }



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchMemberDetails();
    unpaidLoanDetails();
    getLoanBalance();
    getMemberUnpaidLoans();
    checkMemberLoans();
    getLoanStatus();
    getMemberLoansHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: colors.green,
        elevation: 2,
        title: Text('Flash Loan', style: TextStyle(color: colors.white),),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Center(child: Text('Coming soon!!')),
                  PhysicalModel(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(8),
                      elevation: 2,
                      child: Container(
                        height: 100,
                        width: MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8)
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FutureBuilder<Member>(
                            future: _fetchMemberDetails(),
                            builder: (context, snapshot){
                              if(snapshot.connectionState == ConnectionState.waiting){
                                return const Text('Please wait...');
                              }
                              else if (snapshot.hasError) {
                                return const Text('Error!');
                              }
                              else{
                                Member? member = snapshot.data;
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    Text('Greetings ${member?.firstName}!!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: colors.green),),
                                  ],
                                );
                              }
                            },
                          ),
                            const Text('Welcome to Flash Loan')
                          ]
                        ),
                      )
                  ),
                  const SizedBox(height: 12,),
                  FutureBuilder(
                    future: checkMemberLoans(),
                      builder: (context, snapshot){
                      if(snapshot.connectionState == ConnectionState.waiting){
                        return const  SizedBox(
                            height: 200,
                            child: Center(child: Text("Loading..."),));
                      }
                      else if(snapshot.hasError){
                        return const SizedBox(
                          height: 200,
                          child: Center(child: Text("Error loading..."),),
                        );
                      }
                      bool hasLoan = snapshot.data!;
                      if(hasLoan){
                        return PhysicalModel(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(8),
                            elevation: 2,
                            child: Container(
                              height: 160,
                              width: MediaQuery.of(context).size.width,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8)
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  FutureBuilder(
                                      future: unpaidLoanDetails(),
                                      builder: (context, snapshot){
                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                          return const Center(child: Text('Please wait...'));
                                        }
                                        else if (snapshot.hasError) {
                                          // Navigator.pop(context);
                                          return const Text('Error!');
                                        }
                                        else{
                                          FlashLoanModel? loan = snapshot.data;
                                          // var loanAmount = (loan!.amount)! - (totalAmount!);
                                          return Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('Loan owed by ${DateFormat("dd MMM yyyy").format(DateTime.parse(loan!.repayDate!))}', style: const TextStyle(fontWeight: FontWeight.bold),),
                                              const SizedBox(height: 20,),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  FutureBuilder(
                                                    future: getLoanBalance(),
                                                      builder: (context, snapshot){
                                                        if(snapshot.connectionState == ConnectionState.waiting){
                                                          return const Text("Please wait..");
                                                        }
                                                        else if(snapshot.hasError){
                                                          return const Text("error");
                                                        }
                                                        double balance = snapshot.data!;
                                                        return Text('Ksh $balance', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: colors.green),);
                                                      }
                                                  ),
                                                  loan.loanStatus == 'APPROVED' ? Text("Status: ${Formatter().formatAsTitle(loan.loanStatus!)}",
                                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: colors.green)):
                                                  Text("Status: ${Formatter().formatAsTitle(loan.loanStatus!)}",
                                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.deepOrange)),
                                                ],
                                              ),
                                              const SizedBox(height: 20,),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  const Text('Repayment Date:',style: TextStyle(fontWeight: FontWeight.bold)),
                                                  Text(DateFormat('dd MMM yyyy').format(DateTime.parse(loan!.repayDate!)))
                                                ],
                                              ),
                                            ],
                                          );
                                        }
                                      }
                                  ),

                                ],
                              ),
                            )
                        );
                      }
                      else{
                        return PhysicalModel(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(8),
                            elevation: 2,
                            child: Container(
                              height: 200,
                              width: MediaQuery.of(context).size.width,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8)
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  FutureBuilder(
                                    future: getLoanLimit(),
                                    builder: (context, snapshot) {
                                      if(snapshot.connectionState == ConnectionState.waiting){
                                        return const Center(child: Text("Loading.."),);
                                      }
                                      else
                                        if(snapshot.hasError){
                                        return const SizedBox(height: 100,child: Center(child: Text("Error in loading.."),),);
                                      }
                                      else{
                                        double limit = snapshot.data!;
                                        loanLimit = limit;
                                        return SizedBox(
                                          height: 160,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text('Congratulations! You qualify upto Ksh ${limit.toInt()}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Theme.of(context).colorScheme.tertiary),),
                                              const SizedBox(height: 12,),
                                              MyDivider(),
                                              const SizedBox(height: 12,),
                                              const Text("You can borrow upto your maximum limit. The more you borrow and repay in time, the more your limit increases."),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: [
                                                  RoundedButton(
                                                    color: Colors.deepOrange,
                                                    text: 'Apply',
                                                    onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=> ApplyFlashLoan(limit: limit,))),
                                                    width: 120,
                                                    height: 36,
                                                    borderRadius: BorderRadius.circular(24),
                                                  ),
                                                ],
                                              )

                                            ],
                                          ),
                                        );
                                      }
                                    }
                                  ),
                                  // Row(
                                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  //   children: [
                                  //     const Text('Enter Amount:'),
                                  //     SizedBox(
                                  //       width: 120,
                                  //       height: 56,
                                  //       child: NumericTextField(
                                  //           controller: _amountController,
                                  //           validator: (value){},
                                  //           hintText: 'amount'),
                                  //     )
                                  //   ],
                                  // ),

                                  // const Text('Repayment date:'),
                                  // Row(
                                  //   // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  //   children: [
                                  //     IconButton(
                                  //         onPressed: ()=>_showDatePicker(),
                                  //         icon: const Icon(FontAwesomeIcons.calendarDays)
                                  //     ),
                                  //     const Icon(FontAwesomeIcons.caretDown),
                                  //     Text(DateFormat('dd MMM yyyy').format(_selectedDate)),
                                  //   ],
                                  // ),

                                  // const SizedBox(height: 8,),
                                  // _sliderValue != 0.0 ? Row(
                                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  //   children: [
                                  //     const Text('Amount Repayable:',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold)),
                                  //     _selectedDate.difference(DateTime.now()).inDays>0?Text('Ksh ${calculateLoanAmount(_selectedDate, _sliderValue)}',style: const TextStyle(fontSize: 18,fontWeight: FontWeight.bold)):Text('$_sliderValue')
                                  //   ],
                                  // ):const Text(''),
                                  const SizedBox(height: 8,),
                                ],
                              ),
                            )
                        );
                      }
                      },
                  ),
                  // _hasLoan! ? PhysicalModel(
                  //     color: Theme.of(context).colorScheme.primary,
                  //     borderRadius: BorderRadius.circular(8),
                  //     elevation: 2,
                  //     child: Container(
                  //       height: 160,
                  //       width: MediaQuery.of(context).size.width,
                  //       padding: const EdgeInsets.symmetric(horizontal: 12),
                  //       decoration: BoxDecoration(
                  //           borderRadius: BorderRadius.circular(8)
                  //       ),
                  //       child: Column(
                  //       crossAxisAlignment: CrossAxisAlignment.start,
                  //       mainAxisAlignment: MainAxisAlignment.spaceAround,
                  //       children: [
                  //         FutureBuilder(
                  //           future: unpaidLoanDetails(),
                  //             builder: (context, snapshot){
                  //               if (snapshot.connectionState == ConnectionState.waiting) {
                  //                 return const Center(child: Text('Please wait...'));
                  //               }
                  //               else if (snapshot.hasError) {
                  //                 // Navigator.pop(context);
                  //                 return const Text('Error!');
                  //               }
                  //               else{
                  //                 FlashLoanModel? loan = snapshot.data;
                  //                 // var loanAmount = (loan!.amount)! - (totalAmount!);
                  //                 return Column(
                  //                   crossAxisAlignment: CrossAxisAlignment.start,
                  //                   children: [
                  //                     Text('Loan owed by ${DateFormat.yMMMEd().format(DateTime.parse(loan!.repayDate!))}', style: TextStyle(fontWeight: FontWeight.bold),),
                  //                     const SizedBox(height: 20,),
                  //                     Text('Ksh $balance', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: colors.green),),
                  //                     const SizedBox(height: 20,),
                  //                     Row(
                  //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //                       children: [
                  //                         const Text('Repayment Date:',style: TextStyle(fontWeight: FontWeight.bold)),
                  //
                  //                         Text(DateFormat.yMMMEd().format(DateTime.parse(loan!.repayDate!)))
                  //                       ],
                  //                     ),
                  //                     // MyDivider(),
                  //                     // SizedBox(height: 12,),
                  //                     // Row(
                  //                     //   mainAxisAlignment: MainAxisAlignment.center,
                  //                     //   children: [
                  //                     //     RoundedButton(
                  //                     //       color: colors.green,
                  //                     //       text: 'Make a Payment',
                  //                     //       onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>FlashPaymentPage(amount: loan.amount!, loanId: loan.id!,))),
                  //                     //           // flashLoanRepaymentBottomSheet(context, loan?.amount),//open a payment bottom sheet
                  //                     //       width: MediaQuery.of(context).size.width/1.11,
                  //                     //       height: 48,
                  //                     //       borderRadius: BorderRadius.circular(24),
                  //                     //     ),
                  //                     //   ],
                  //                     // )
                  //                   ],
                  //                 );
                  //               }
                  //             }
                  //         ),
                  //
                  //       ],
                  //     ),
                  //     )
                  // ):
                  // PhysicalModel(
                  //     color: Theme.of(context).colorScheme.primary,
                  //     borderRadius: BorderRadius.circular(8),
                  //     elevation: 2,
                  //     child: Container(
                  //       height: 320,
                  //       width: MediaQuery.of(context).size.width,
                  //       padding: const EdgeInsets.all(16),
                  //       decoration: BoxDecoration(
                  //           borderRadius: BorderRadius.circular(8)
                  //       ),
                  //       child: Column(
                  //         crossAxisAlignment: CrossAxisAlignment.start,
                  //         children: [
                  //           Text('Congratulations! You qualify for upto Ksh ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: colors.green),),
                  //           const SizedBox(height: 4,),
                  //           MyDivider(),
                  //           const SizedBox(height: 12,),
                  //           const Text('Select Amount:'),
                  //           Slider(
                  //               value: _sliderValue,
                  //               min:0.0,
                  //               max: loanLimit!,
                  //               divisions: 100,
                  //               onChanged: (value){
                  //                 setState(() {
                  //                   _sliderValue=value.roundToDouble();
                  //                 });
                  //               },
                  //             thumbColor: colors.green,
                  //             activeColor: colors.green,
                  //             inactiveColor: Theme.of(context).colorScheme.secondary,
                  //             focusNode: FocusNode(),
                  //           ),
                  //           Row(
                  //             mainAxisAlignment: MainAxisAlignment.end,
                  //             children: [
                  //               _sliderValue!= 0.0 ?Text('Ksh $_sliderValue', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: colors.green),):Text(''),
                  //             ]
                  //           ),
                  //           const Text('Repayment date:'),
                  //           Row(
                  //             // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //             children: [
                  //               IconButton(
                  //                   onPressed: ()=>_showDatePicker(),
                  //                   icon: const Icon(FontAwesomeIcons.calendarDays)
                  //               ),
                  //               const Icon(FontAwesomeIcons.caretDown),
                  //               Text(DateFormat('dd MMM yyyy').format(_selectedDate)),
                  //
                  //             ],
                  //           ),
                  //
                  //           const SizedBox(height: 8,),
                  //           _sliderValue != 0.0 ? Row(
                  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //             children: [
                  //               const Text('Amount Repayable:',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold)),
                  //               _selectedDate.difference(DateTime.now()).inDays>0?Text('Ksh ${calculateLoanAmount(_selectedDate, _sliderValue)}',style: const TextStyle(fontSize: 18,fontWeight: FontWeight.bold)):Text('$_sliderValue')
                  //             ],
                  //           ):const Text(''),
                  //           const SizedBox(height: 8,),
                  //           RoundedButton(
                  //             color: colors.green,
                  //             text: 'Submit Application',
                  //             onTap: () async {
                  //               SharedPreferences pref = await SharedPreferences.getInstance();
                  //               Map<String, dynamic> data = {
                  //                 'repayDate':_selectedDate.toString(),
                  //                 'principal': _sliderValue,
                  //                 'loanStatus':'REVIEWING',
                  //                 'amount': calculateLoanAmount(_selectedDate, _sliderValue),
                  //                 "memberId": pref.getString("id")
                  //               };
                  //               if(_sliderValue==0.0){
                  //                 MyToast().showToast("Select loan amount");
                  //               }
                  //               else if(_selectedDate.difference(DateTime.now()).inDays==0){
                  //                 MyToast().showToast('Select date to repay');
                  //               }
                  //               else {
                  //                 showDialog(
                  //                   context: context,
                  //                   builder: (context){
                  //                     return Center(
                  //                       child: CircularProgressIndicator(color: colors.green,),
                  //                     );
                  //                   },
                  //                 );
                  //                 try {
                  //                   Response res = await FlashLoanController()
                  //                       .applyFlashLoan(data);
                  //                   Map<String, dynamic> jsonMap = jsonDecode(res.body);
                  //                   if (res.statusCode == 200) {
                  //                     MyToast().showToast(
                  //                         jsonMap['message']);
                  //                     setState(() {
                  //                       _hasLoan = true;
                  //                     });
                  //                     Navigator.pop(context);
                  //                   }
                  //                   else {
                  //                     MyToast().showToast(
                  //                         jsonMap['message']);
                  //                     Navigator.pop(context);
                  //
                  //                   }
                  //                 }
                  //                 catch(e){
                  //                   print(e.toString());
                  //                 }
                  //               }
                  //             },
                  //             width: MediaQuery.of(context).size.width/1.11,
                  //             height: 48,
                  //             borderRadius: BorderRadius.circular(24),
                  //           ),
                  //         ],
                  //       ),
                  //     )
                  // ),
                  const SizedBox(height: 12,),
                  PhysicalModel(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(8),
                      elevation: 2,
                      child: Container(
                        height: 160,
                        width: MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8)
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('View Loan History', style: TextStyle(fontWeight: FontWeight.bold, color: colors.green, fontSize: 16),),
                            const SizedBox(height: 12,),
                            const Text('Note that you limit is determined by your loaning history. Take more loans and repay in time to increase your limit.'),
                            const SizedBox(height: 12,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                RoundedButton(
                                    color: colors.green,
                                    onTap: ()=>loanHistoryBottomSheet(context),
                                    text: 'View',
                                    width: 120,
                                    height: 36.0,
                                    borderRadius: BorderRadius.circular(24)),
                              ],
                            ),
                          ],
                        ),
                      )
                  ),
                   const SizedBox(height: 12,),
                  PhysicalModel(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(8),
                      elevation: 2,
                      child: Container(
                        height: 140,
                        width: MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8)
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Need Help?',style: TextStyle(fontWeight: FontWeight.bold, color: colors.green, fontSize: 16)),
                            const SizedBox(height: 12,),
                            const Text('Get to learn more about our product'),
                            const SizedBox(height: 12,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                RoundedButton(
                                    color: colors.green,
                                    onTap: ()=>faqsBottomSheet(context),
                                    text: 'FAQs',
                                    width: 120,
                                    height: 36.0,
                                    borderRadius: BorderRadius.circular(24)),
                              ],
                            ),
                          ],
                        ),
                      )
                  ),
                  const SizedBox(height: 12,),
                  PhysicalModel(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(8),
                      elevation: 2,
                      child: Container(
                        height: 140,
                        width: MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8)
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Terms and Conditions',style: TextStyle(fontWeight: FontWeight.bold, color: colors.green, fontSize: 16)),
                            const SizedBox(height: 12,),
                            const Text('Read our terms and conditions.'),
                            const SizedBox(height: 12,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                RoundedButton(
                                    color: colors.green,
                                    onTap: ()=>termsBottomSheet(context),
                                    text: 'Read',
                                    width: 120,
                                    height: 36.0,
                                    borderRadius: BorderRadius.circular(24)),
                              ],
                            ),
                          ],
                        ),
                      )
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<dynamic> loanHistoryBottomSheet(BuildContext context){
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
          return Container(
            height: MediaQuery.of(context).size.height/1.1,
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.background,
                borderRadius: BorderRadius.circular(10.0)
            ),
            child: Column(
              children: [
                const SizedBox(height: 12,),
                Container(
                  height: 60,
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.symmetric(horizontal: 12.0),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colors.green,
                    borderRadius: BorderRadius.circular(8),
                    // border: Border.all(width: 1.0)
                  ),
                  child: Text('Loan History', style: TextStyle(fontWeight: FontWeight.bold, color: colors.white),),
                ),
                const SizedBox(height: 8,),
                const SizedBox(height: 8.0),
                Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: FutureBuilder(
                        future: getMemberLoansHistory(),
                        builder: (context, snapshot){
                          if(snapshot.hasData){
                            loanList = snapshot.data!;
                            if(loanList!.isEmpty){
                              return const Center(child: Text("No Data"),);
                            }
                            return LiquidPullToRefresh(
                              onRefresh: ()=>getMemberLoansHistory(),
                              showChildOpacityTransition: false,
                              backgroundColor: colors.green,
                              color: Colors.transparent,
                              height: 80,
                              child: ListView.builder(
                                itemCount: loanList!.length,
                                itemBuilder: (BuildContext context, int index){
                                  FlashLoanModel? loan = loanList![index];
                                  return Container(
                                    height: 160,
                                    padding: const EdgeInsets.all(12),
                                    margin: const EdgeInsets.symmetric(vertical: 6.0),
                                    decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.primary,
                                        borderRadius: BorderRadius.circular(10)
                                    ),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text("#${loan.id} Applied on ${DateFormat("dd MMM yyyy").format(DateTime.parse(loan.applicationDate!))}"),
                                            loan.repaidInTime==true ? Container(
                                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                              decoration: BoxDecoration(
                                                  color: colors.green,
                                                  borderRadius: BorderRadius.circular(10)
                                              ),
                                              child: Text("Paid on time", style: TextStyle(color: colors.white),),
                                            ):
                                            Container(
                                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                            decoration: BoxDecoration(
                                            color: Colors.deepOrange,
                                            borderRadius: BorderRadius.circular(10)
                                            ),
                                            child: Text("Paid Late",style: TextStyle(color: colors.white)),
                                            )
                                          ],
                                        ),
                                        const SizedBox(height: 12,),
                                        MyDivider(),
                                        const SizedBox(height: 12,),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text("Loan Amount"),
                                            Text("Ksh ${loan.principal}")
                                          ],
                                        ),
                                        const SizedBox(height: 12,),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text("Amount Repaid"),
                                            Text("Ksh ${loan.amountPaid!}")
                                          ],
                                        ),
                                        const SizedBox(height: 12,),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text("Amount Due"),
                                            Text("Ksh ${(loan.amount)!-(loan.amountPaid!.toDouble())+loan.processingFee!}")
                                          ],
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
                      ),
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
          );
        }
    );
  }

  Future<dynamic> faqsBottomSheet(BuildContext context){
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
          return Container(
            height: MediaQuery.of(context).size.height/1.1,
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.background,
                borderRadius: BorderRadius.circular(10.0)
            ),
            // padding: EdgeInsets.all(8),
            child: Column(
              children: [
                // const SizedBox(height: 12,),
                Container(
                  height: 60,
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.symmetric(vertical: 4.0),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colors.green,
                    borderRadius: BorderRadius.circular(8),
                    // border: Border.all(width: 1.0)
                  ),
                  child: Text('FAQs', style: TextStyle(fontWeight: FontWeight.bold, color: colors.white),),
                ),
                const SizedBox(height: 12,),
                Expanded(
                    child: ListView(
                      children: [
                        Container(
                          height: 100,
                          padding: const EdgeInsets.all(8.0),
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(8)
                          ),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Q: Who is eligible to apply for a Sojrel Sacco flash loan?", style: TextStyle(fontWeight: FontWeight.bold),),
                              Text("A: Flash loans are exclusively available to registered Sojrel Sacco members who meet the qualification criteria set by the Sacco.")
                            ],
                          ),
                        ),
                        Container(
                          height: 100,
                          padding: const EdgeInsets.all(8.0),
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(8)
                          ),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Q: What is the maximum loan amount one can borrow?",style: TextStyle(fontWeight: FontWeight.bold)),
                              Text("A: The maximum loan amount for a flash loan is Ksh 10,000, subject to the member's eligibility and creditworthiness.")
                            ],
                          ),
                        ),
                        Container(
                          height: 100,
                          padding: const EdgeInsets.all(8.0),
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(8)
                          ),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Q: What is the repayment period for a flash loan?", style: TextStyle(fontWeight: FontWeight.bold)),
                              Text("A: Flash loans are repayable within one month or a shorter period as specified in the loan agreement.")
                            ],
                          ),
                        ),
                        Container(
                          height: 100,
                          padding: const EdgeInsets.all(8.0),
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(8)
                          ),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Q: What comprises the repayment amount?", style: TextStyle(fontWeight: FontWeight.bold)),
                              Text("A: The repayment amount includes the borrowed principal, interest calculated at 2.5% per month, and a processing fee.")
                            ],
                          ),
                        ),
                        Container(
                          height: 100,
                          padding: const EdgeInsets.all(8.0),
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(8)
                          ),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Q: Are there benefits for timely repayment?", style: TextStyle(fontWeight: FontWeight.bold)),
                              Text("A: Yes, members who repay their loans on time receive an increased loan limit. Late repayments may result in penalties and affect the loan limit.")
                            ],
                          ),
                        ),
                        Container(
                          height: 100,
                          padding: const EdgeInsets.all(8.0),
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(8)
                          ),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Q: What happens if a loan is not repaid in time?", style: TextStyle(fontWeight: FontWeight.bold)),
                              Text("A: Failure to repay the loan on time may result in penalties, an unchanged or reduced loan limit, or denial of future loan services.")
                            ],
                          ),
                        )
                      ],
                    )
                ),

              ],
            ),
          );
        }
    );
  }

  Future<dynamic> termsBottomSheet(BuildContext context){
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
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.background,
                borderRadius: BorderRadius.circular(10.0)
            ),
            height: MediaQuery.of(context).size.height/1.12,
            // padding: EdgeInsets.all(8),
            child: Column(
              children: [
                const SizedBox(height: 12,),
                Container(
                  height: 60,
                  width: MediaQuery.of(context).size.width,
                  // margin: const EdgeInsets.symmetric(horizontal: 12.0),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colors.green,
                    borderRadius: BorderRadius.circular(8),
                    // border: Border.all(width: 1.0)
                  ),
                  child: Text('Terms and Conditions', style: TextStyle(fontWeight: FontWeight.bold, color: colors.white),),
                ),
                const SizedBox(height: 12,),
                Expanded(
                  child: ListView(
                    children: const [
                      Text("1. Eligibility: Flash loans are exclusively available to registered members of Sojrel Sacco who meet the eligibility criteria established by the Sacco.", style: TextStyle(fontSize: 16),),
                      Text("2. Loan Limit: The maximum loan amount for a flash loan is 10,000. The actual loan amount approved is subject to individual member eligibility and credit assessment.", style: TextStyle(fontSize: 16)),
                      Text("3. Repayment Period: Flash loans are to be repaid within one month or a shorter period specified in the loan agreement. Late repayments may attract penalties.", style: TextStyle(fontSize: 16)),
                      Text("4. Repayment Amount: The repayment amount includes the borrowed principal, interest at a rate of 2.5% per month, and a processing fee.", style: TextStyle(fontSize: 16)),
                      Text("5. Timely Repayment Benefits: Members who repay their loans on time are eligible for an increased loan limit, whereas late repayments may impact the loan limit negatively.", style: TextStyle(fontSize: 16)),
                      Text("6. Penalties: Late repayment may result in penalties and continued accrual of interest, leading to higher repayment amounts in subsequent periods.", style: TextStyle(fontSize: 16)),
                      Text("7. Loan Limit Adjustments: Failure to repay loans on time may result in unchanged or reduced loan limits and could lead to denial of future loan services.", style: TextStyle(fontSize: 16)),
                      Text("8. Loan Usage: Flash loans are intended for short-term financial needs and should not be used for long-term borrowing.", style: TextStyle(fontSize: 16)),
                      // Container(
                      //   height: 80,
                      //   margin: const EdgeInsets.symmetric(vertical: 6),
                      //   padding: const EdgeInsets.all(8.0),
                      //   decoration: BoxDecoration(
                      //       color: Theme.of(context).colorScheme.secondary,
                      //       borderRadius: BorderRadius.circular(8)
                      //   ),
                      //
                      // ),
                      // Container(
                      //   height: 80,
                      //   margin: const EdgeInsets.symmetric(vertical: 6),
                      //   padding: const EdgeInsets.all(8.0),
                      //   decoration: BoxDecoration(
                      //       color: Theme.of(context).colorScheme.secondary,
                      //       borderRadius: BorderRadius.circular(8)
                      //   ),
                      //   child: const
                      // ),
                      // Container(
                      //   height: 80,
                      //   margin: const EdgeInsets.symmetric(vertical: 6),
                      //   padding: const EdgeInsets.all(8.0),
                      //   decoration: BoxDecoration(
                      //       color: Theme.of(context).colorScheme.secondary,
                      //       borderRadius: BorderRadius.circular(8)
                      //   ),
                      //   child: const
                      // ),
                      // Container(
                      //   height: 80,
                      //   margin: const EdgeInsets.symmetric(vertical: 6),
                      //   padding: const EdgeInsets.all(8.0),
                      //   decoration: BoxDecoration(
                      //       color: Theme.of(context).colorScheme.secondary,
                      //       borderRadius: BorderRadius.circular(8)
                      //   ),
                      //   child: const
                      // ),
                      // Container(
                      //   height: 80,
                      //   margin: const EdgeInsets.symmetric(vertical: 6),
                      //   padding: const EdgeInsets.all(8.0),
                      //   decoration: BoxDecoration(
                      //       color: Theme.of(context).colorScheme.secondary,
                      //       borderRadius: BorderRadius.circular(8)
                      //   ),
                      //   child: const
                      // ),
                      // Container(
                      //   height: 80,
                      //   margin: const EdgeInsets.symmetric(vertical: 6),
                      //   padding: const EdgeInsets.all(8.0),
                      //   decoration: BoxDecoration(
                      //       color: Theme.of(context).colorScheme.secondary,
                      //       borderRadius: BorderRadius.circular(8)
                      //   ),
                      //   child: const
                      // ),
                      // Container(
                      //   height: 80,
                      //   margin: const EdgeInsets.symmetric(vertical: 6),
                      //   padding: const EdgeInsets.all(8.0),
                      //   decoration: BoxDecoration(
                      //       color: Theme.of(context).colorScheme.secondary,
                      //       borderRadius: BorderRadius.circular(8)
                      //   ),
                      //   child: const
                      // )
                    ],
                  ),
                )

              ],
            ),
          );
        }
    );
  }

  // Future<dynamic> flashLoanRepaymentBottomSheet(BuildContext context, amount){
  //   return showModalBottomSheet(
  //       context: context,
  //       isScrollControlled: true,
  //       isDismissible: false,
  //       shape: const RoundedRectangleBorder(
  //         borderRadius: BorderRadius.only(
  //             topLeft: Radius.circular(12),
  //             topRight: Radius.circular(12)
  //         ),
  //       ),
  //       builder: (BuildContext context){
  //           return StatefulBuilder(
  //           builder: (BuildContext context, StateSetter myState) {
  //             return SizedBox(
  //               height: MediaQuery.of(context).size.height/1.5,
  //               child: SingleChildScrollView(
  //                 child: Padding(
  //                   padding: const EdgeInsets.all(8.0),
  //                   child: Column(
  //                     children: [
  //                       const SizedBox(height: 16,),
  //                       SizedBox(
  //                         child: Text('Repay Loan ',style: TextStyle(fontWeight: FontWeight.bold, fontSize:18, color: colors.green)),
  //                       ),
  //                       const SizedBox(height: 12,),
  //                       MyDivider(),
  //                       const SizedBox(height: 12,),
  //                       SizedBox(
  //                           child: Column(
  //                             children: [
  //                               const Text('Payment Amount:', style: TextStyle(fontSize: 16),),
  //                               const SizedBox(height: 12,),
  //                               Text('Ksh $amount', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
  //                               const SizedBox(height: 12,),
  //                               MyDivider(),
  //                           Column(
  //                             children: <Widget>[
  //                               ListTile(
  //                                 title: const Text('Lafayette'),
  //                                 leading: Radio<SingingCharacter>(
  //                                   value: SingingCharacter.lafayette,
  //                                   groupValue: _character,
  //                                   onChanged: (SingingCharacter? value) {
  //                                     setState(() {
  //                                       _character = value;
  //                                     });
  //                                   },
  //                                 ),
  //                               ),
  //                               ListTile(
  //                                 title: const Text('Thomas Jefferson'),
  //                                 leading: Radio<SingingCharacter>(
  //                                   value: SingingCharacter.jefferson,
  //                                   groupValue: _character,
  //                                   onChanged: (SingingCharacter? value) {
  //                                     setState(() {
  //                                       _character = value;
  //                                     });
  //                                   },
  //                                 ),
  //                               ),
  //                             ],
  //                           ),
  //                               Row(
  //                                 children: [
  //                                   Radio(
  //                                       fillColor: MaterialStateProperty.resolveWith(colors.getColor),
  //                                       value: 1,
  //                                       groupValue: _option,
  //                                       onChanged: (value){
  //                                         myState(() {
  //                                           value = _option;
  //                                           _amountController.text = amount.toString();
  //                                         });
  //                                       }
  //                                   ),
  //                                   // Checkbox(
  //                                   //   value: isChecked,
  //                                   //   checkColor: Colors.white,
  //                                   //   fillColor: MaterialStateProperty.resolveWith(colors.getColor),
  //                                   //   onChanged: (bool? value) {
  //                                   //     setState(() {
  //                                   //       isChecked = value!;
  //                                   //       _amountController.text = amount.toString();
  //                                   //     });
  //                                   //   },
  //                                   // ),
  //                                   const Text('Pay full amount')
  //                                 ],
  //                               ),
  //                               Row(
  //                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                                 children: [
  //                                   Row(
  //                                     children: [
  //                                       Radio(
  //                                           fillColor: MaterialStateProperty.resolveWith(colors.getColor),
  //                                           value: 2,
  //                                           groupValue: _option,
  //                                           onChanged: (value){
  //                                             myState(() {
  //                                               value = _option;
  //                                             });
  //                                           }
  //                                       ),
  //                                       // Checkbox(
  //                                       //   value: isPartial,
  //                                       //   fillColor: MaterialStateProperty.resolveWith(colors.getColor),
  //                                       //   onChanged: (bool? value) {
  //                                       //     setState(() {
  //                                       //       isPartial = value!;
  //                                       //     });
  //                                       //   },
  //                                       // ),
  //                                       const Text('Make partial payment'),
  //                                     ],
  //                                   ),
  //                                   // const SizedBox(width: 2,),
  //                                   const SizedBox(width: 12,),
  //                                   _option == 2 ? SizedBox(
  //                                     width: MediaQuery.of(context).size.width/3,
  //                                     height: 56,
  //                                     child: NumericTextField(
  //                                         controller: _amountController,
  //                                         validator: (value){
  //                                           if(value == null){
  //
  //                                           }
  //                                         },
  //                                         hintText: 'Enter amount'
  //                                     ),
  //                                   ):const Text(''),
  //                                 ],
  //                               ),
  //
  //                               const SizedBox(height: 24,),
  //                               MyRaisedButton(
  //                                 text: 'Make payment',
  //                                 onTap: () {
  //                                   print(_amountController.text);
  //                                 },
  //                               )
  //                             ],
  //                           )
  //                       ),
  //                       // SizedBox(height: 12,),
  //                     ],
  //                   ),
  //                 ),
  //               ),
  //             );
  //           });
  //
  //       }
  //   );
  // }


}
