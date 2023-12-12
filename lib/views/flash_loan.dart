import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
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
import 'flash_payment.dart';


class FlashLoan extends StatefulWidget {
  const FlashLoan({super.key});

  @override
  State<FlashLoan> createState() => _FlashLoanState();
}

class _FlashLoanState extends State<FlashLoan> {
  MyColors colors = MyColors();
  TextEditingController _amountController = TextEditingController();
  bool _hasLoan = true;
  double _sliderValue = 0.0;
  FlashLoanModel? loan;
  DateTime _selectedDate = DateTime.now();
  bool isChecked = false;
  bool isPartial = false;

  String? _name;
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


  double amount = 0.0;
  int timeInDays = 0;
  double calculateLoanAmount(DateTime selectedDate, double principal){
    setState(() {
      timeInDays = selectedDate.difference(DateTime.now()).inDays;
      double interest = principal*0.1*timeInDays/30;
      int a = interest.toInt() % 10;
      int roundedAmount = (interest ~/ 10) * 10;
      amount = principal+roundedAmount;

    });

    return amount.roundToDouble();
  }

  Future<List<FlashLoanModel>?> getMemberUnpaidLoans() async{
    Member member = await MemberDetails().fetchMemberDetails();
    List<FlashLoanModel> loans = member.flashLoans!;
    List<FlashLoanModel> flashLoans=[];
    for (var e in loans) {
      if(e.loanStatus == 'REVIEWING'||e.loanStatus == 'APPROVED'){
        flashLoans.add(e);
      }
    }
    return flashLoans;

  }

  Future<void> checkMemberLoans() async{
    List<FlashLoanModel>? list = await getMemberUnpaidLoans();
    if(list!.isEmpty){
      setState(() {
        _hasLoan = false;
      });
    }
    else{
      setState(() {
        _hasLoan=true;
      });
    }

  }
  Future<FlashLoanModel?> unpaidLoanDetails() async{
    List<FlashLoanModel>? list = await getMemberUnpaidLoans();
    FlashLoanModel? loanModel;
    if(list!.isNotEmpty){
      loanModel = list.elementAt(0);
    }
    return loanModel;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchMemberDetails();
    unpaidLoanDetails();
    checkMemberLoans();

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
                                // Navigator.pop(context);
                                return const Text('Error!');
                              }
                              else{
                                Member? member = snapshot.data;
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    Text('Greetings ${member?.firstName}!!', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),),
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
                  _hasLoan ? PhysicalModel(
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
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Loan owed by ${DateFormat.yMMMEd().format(DateTime.parse(loan!.repayDate!))}', style: TextStyle(fontWeight: FontWeight.bold),),
                                      const SizedBox(height: 20,),
                                      Text('Ksh ${loan?.amount!}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: colors.green),),
                                      const SizedBox(height: 20,),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text('Repayment Date:',style: TextStyle(fontWeight: FontWeight.bold)),

                                          Text(DateFormat.yMMMEd().format(DateTime.parse(loan!.repayDate!)))
                                        ],
                                      ),
                                      // MyDivider(),
                                      // SizedBox(height: 12,),
                                      // Row(
                                      //   mainAxisAlignment: MainAxisAlignment.center,
                                      //   children: [
                                      //     RoundedButton(
                                      //       color: colors.green,
                                      //       text: 'Make a Payment',
                                      //       onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>FlashPaymentPage(amount: loan.amount!, loanId: loan.id!,))),
                                      //           // flashLoanRepaymentBottomSheet(context, loan?.amount),//open a payment bottom sheet
                                      //       width: MediaQuery.of(context).size.width/1.11,
                                      //       height: 48,
                                      //       borderRadius: BorderRadius.circular(24),
                                      //     ),
                                      //   ],
                                      // )
                                    ],
                                  );
                                }
                              }
                          ),

                        ],
                      ),
                      )
                  ):
                  PhysicalModel(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(8),
                      elevation: 2,
                      child: Container(
                        height: 320,
                        width: MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8)
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Congratulations! You qualify for a flash loan', style: TextStyle(fontWeight: FontWeight.bold),),
                            const SizedBox(height: 4,),
                            MyDivider(),
                            const SizedBox(height: 12,),
                            const Text('Select Amount:'),
                            Slider(
                                value: _sliderValue,
                                min:0.0,
                                max: 10000,
                                divisions: 100,
                                onChanged: (value){
                                  setState(() {
                                    _sliderValue=value.roundToDouble();
                                  });
                                },
                              thumbColor: colors.green,
                              activeColor: colors.green,
                              inactiveColor: Theme.of(context).colorScheme.secondary,
                              focusNode: FocusNode(),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                _sliderValue!= 0.0 ?Text('Ksh $_sliderValue', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: colors.green),):Text(''),
                              ]
                            ),
                            const Text('Repayment date:'),
                            Row(
                              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                    onPressed: ()=>_showDatePicker(),
                                    icon: const Icon(FontAwesomeIcons.calendarDays)
                                ),
                                const Icon(FontAwesomeIcons.caretDown),
                                Text(DateFormat('dd MMM yyyy').format(_selectedDate)),

                              ],
                            ),

                            const SizedBox(height: 8,),
                            _sliderValue != 0.0 ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Amount Repayable:',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold)),
                                _selectedDate.difference(DateTime.now()).inDays>0?Text('Ksh ${calculateLoanAmount(_selectedDate, _sliderValue)}',style: const TextStyle(fontSize: 18,fontWeight: FontWeight.bold)):Text('$_sliderValue')
                              ],
                            ):const Text(''),
                            const SizedBox(height: 8,),
                            RoundedButton(
                              color: colors.green,
                              text: 'Submit Application',
                              onTap: () async {
                                SharedPreferences pref = await SharedPreferences.getInstance();
                                Map<String, dynamic> data = {
                                  'repayDate':_selectedDate.toString(),
                                  'principal': _sliderValue,
                                  'loanStatus':'REVIEWING',
                                  'amount': calculateLoanAmount(_selectedDate, _sliderValue),
                                  "memberId": pref.getString("id")
                                };
                                if(_sliderValue==0.0){
                                  MyToast().showToast("Select loan amount");
                                }
                                else if(_selectedDate.difference(DateTime.now()).inDays==0){
                                  MyToast().showToast('Select date to repay');
                                }
                                else {
                                  showDialog(
                                    context: context,
                                    builder: (context){
                                      return Center(
                                        child: CircularProgressIndicator(color: colors.green,),
                                      );
                                    },
                                  );
                                  try {
                                    Response res = await FlashLoanController()
                                        .applyFlashLoan(data);
                                    Map<String, dynamic> jsonMap = jsonDecode(res.body);
                                    if (res.statusCode == 200) {
                                      // print(res.body);
                                      MyToast().showToast(
                                          jsonMap['message']);
                                      Navigator.pop(context);

                                      //show another box on loan owed
                                    }
                                    else {
                                      // print(res.body);
                                      MyToast().showToast(
                                          jsonMap['message']);
                                      Navigator.pop(context);

                                    }
                                  }
                                  catch(e){
                                    print(e.toString());
                                  }
                                }
                              },
                              width: MediaQuery.of(context).size.width/1.11,
                              height: 48,
                              borderRadius: BorderRadius.circular(24),
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
                                    onTap: (){},
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
                                    onTap: (){},
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
                                    onTap: (){},
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
