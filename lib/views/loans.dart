import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sojrel_sacco_client/components/buttons.dart';
import 'package:sojrel_sacco_client/components/toast.dart';
import 'package:sojrel_sacco_client/models/flash_loan_model.dart';
import 'package:sojrel_sacco_client/services/member_details_service.dart';
import 'package:sojrel_sacco_client/utils/colors.dart';

import '../components/divider.dart';
import '../components/textfields.dart';
import '../controller/loans_controller.dart';
// import '../models/Loan.dart';
import '../models/loan_model.dart';
import '../models/member_model.dart';
import '../services/loans_service.dart';
import 'flash_loan.dart';
import 'guarantee_loan.dart';
import 'guaranteed_loans.dart';
import 'loans_applied.dart';
import 'loans_in_progress.dart';

class LoansPage extends StatefulWidget {
  const LoansPage({super.key});

  @override
  State<LoansPage> createState() => _LoansPageState();
}


class _LoansPageState extends State<LoansPage> {
  MyColors colors = MyColors();
  MyToast toast = MyToast();
  List<Loan>? appliedLoans;
  final _loanApplicationFormKey = GlobalKey<FormState>();
  final _loanAmountController = TextEditingController();
  final _loanInstalmentController = TextEditingController();
  List<Loan>? guaranteedLoans;
  List<Loan>? loans;
  List<Loan>? loansTaken;
  Future<List<Loan>?> getAppliedLoans() async {
    Member member = await MemberDetails().fetchMemberDetails();
    var loans = member.loansTaken;
    return loans;
  }

  Future<List<Loan>?> countAppliedLoans() async {
    // loans = await LoansService().fetchMembersLoans();
    Member member = await MemberDetails().fetchMemberDetails();
    // prefs = await SharedPreferences.getInstance();
    loans = member.loansTaken;
    List<Loan> appliedLoans = [];
    loans?.forEach((e) {
      if (e.loanStatus == 'REVIEW') {
        appliedLoans.add(e);
      }
    });
    return appliedLoans;
  }

  Future<List<Loan>> fetchGuaranteedLoans() async{
    Member member = await MemberDetails().fetchMemberDetails();
    List<Loan>? guaranteedLoans = member.loansGuaranteed;
    List<Loan>? allLoans = await LoansService().getAllLoans();
    List<Loan> loans=[];
    guaranteedLoans?.forEach((e) {
      allLoans?.forEach((i) {
        if(e.id == i.id){
          if(e.loanStatus == 'REVIEW'){
            loans.add(i);
            // print(e.loanType);
          }
        }
      });

    });
    return loans;
  }

  Future<List<Loan>?> fetchLoansTaken() async{
    Member member = await MemberDetails().fetchMemberDetails();
    List<Loan>? takenLoans = member.loansTaken;
    List<Loan>? allLoans = await LoansService().getAllLoans();
    List<Loan> loans = [];
    takenLoans?.forEach((element) {
      allLoans?.forEach((e) {
        if(element.id == e.id){
          if(element.loanStatus != 'REVIEW'){
            loans.add(e);
          }
        }
      });

    });
    return loans;
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
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                PhysicalModel(
                  color: Theme.of(context).colorScheme.primary,
                  elevation: 2,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    // height: MediaQuery.of(context).size.height/4,
                    height: 140,
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(10),
                      // border: Border.all(color: colors.lightGrey, width: 1)
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.account_balance_wallet, color:colors.green,),
                            Text('My Loan Performance', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0, color: colors.green),)
                          ],
                        ),
                        const SizedBox(height: 4,),
                        MyDivider(),
                        const SizedBox(height: 24.0,),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap:()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>const LoansInProgress())),
                                  child: Container(
                                      // width: 170.0,
                                      width: MediaQuery.of(context).size.width/2.4,
                                      height: 48.0,
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      decoration: BoxDecoration(
                                        color: colors.darkGreen,
                                        borderRadius: BorderRadius.circular(8.0)
                                        // shape: BoxShape.circle,
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(FontAwesomeIcons.pen,color: colors.white),
                                          const SizedBox(width: 2,),
                                          Text('Applied Loans', style: TextStyle(color: colors.white),),
                                        ],
                                      )),
                                ),

                              ],
                            ),
                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.end,
                            //   children: [
                            //     RoundedButton(
                            //       onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>const LoansInProgress())),
                            //       text: 'Applied Loans', color: colors.green, width: MediaQuery.of(context).size.width/2.4, height: 36.0, borderRadius: BorderRadius.circular(18.0),)
                            //   ],
                            // ),
                            // SizedBox(
                            //   height: 36,
                            //   child: VerticalDivider(
                            //     width: 1.0,
                            //     color: Theme.of(context).colorScheme.tertiary,
                            //     thickness: 2.0,
                            //     // endIndent: 50,
                            //
                            //   ),
                            // ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap:()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>GuaranteedLoans())),
                                  child: Container(
                                      // width: 170.0,
                                      width: MediaQuery.of(context).size.width/2.4,
                                      height: 48.0,
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.orangeAccent,
                                        borderRadius: BorderRadius.circular(8)
                                        // shape: BoxShape.circle,
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(FontAwesomeIcons.listCheck,color: colors.white),
                                          const SizedBox(width: 2,),
                                          Text('Guaranteed', style: TextStyle(color: colors.white),),
                                        ],
                                      )),
                                ),

                              ],
                            ),
                            // const Text('As a member, you have a responsibility of guaranteeing your trusted members for loans. However, you can consent or reject guaranteeing.',),
                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.end,
                            //   children: [
                            //     RoundedButton(
                            //       // height:36, width:100, colors: colors,
                            //       onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>GuaranteedLoans())),
                            //       text: 'Guaranteed Loans', color: colors.deepOrange, width: MediaQuery.of(context).size.width/2.4, height: 36.0, borderRadius: BorderRadius.circular(18.0),)
                            //   ],
                            // )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 12,),
                SizedBox(
                  // height: MediaQuery.of(context).size.width,
                  child: Column(
                    children: [
                      PhysicalModel(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(8),
                          elevation: 4,
                          child: SizedBox(
                            height: 120,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                          width: 56.0,
                                          height: 56.0,
                                          decoration: new BoxDecoration(
                                            color: Colors.blueAccent,
                                            shape: BoxShape.circle,
                                          ),
                                          child: IconButton(
                                            icon: Icon(FontAwesomeIcons.userClock,color: colors.white), onPressed: () => loansDialog(context, 'EMERGENCY'),
                                            color: colors.green,
                                          )),
                                      Text('Emergency'),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                              width: 56.0,
                                              height: 56.0,
                                              decoration: new BoxDecoration(
                                                color: colors.green,
                                                shape: BoxShape.circle,
                                              ),
                                              child: IconButton(
                                                icon: Icon(FontAwesomeIcons.moneyBill1,color: colors.white), onPressed: () => loansDialog(context, 'NORMAL'),
                                                color: colors.green,
                                              )),
                                          Text('Normal'),
                                        ],
                                      ),
                                    ],

                                  ),
                                  Row(
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                              width: 56.0,
                                              height: 56.0,
                                              decoration: new BoxDecoration(
                                                color: Colors.pinkAccent,
                                                shape: BoxShape.circle,
                                              ),
                                              child: IconButton(
                                                icon: Icon(FontAwesomeIcons.dev,color: colors.white), onPressed: () => loansDialog(context, 'DEVELOPMENT'),
                                                color: colors.green,
                                              )),
                                          Text('Development'),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                              width: 56.0,
                                              height: 56.0,
                                              decoration: new BoxDecoration(
                                                color: Colors.lightBlueAccent,
                                                shape: BoxShape.circle,
                                              ),
                                              child: IconButton(
                                                icon: Icon(FontAwesomeIcons.hammer,color: colors.white), onPressed: () => loansDialog(context, 'JIJENGE'),
                                                color: colors.green,
                                              )),
                                          Text('Jijenge'),
                                        ],
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                      ),
                      SizedBox(
                        height: 12.0,
                      ),
                      PhysicalModel(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(8),
                        elevation: 4,
                        child: SizedBox(
                          height: 120,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                        width: 56.0,
                                        height: 56.0,
                                        decoration: new BoxDecoration(
                                          color: Colors.cyan,
                                          shape: BoxShape.circle,
                                        ),
                                        child: IconButton(
                                          icon: Icon(FontAwesomeIcons.businessTime,color: colors.white), onPressed: () => loansDialog(context, 'BUSINESS'),
                                          color: colors.green,
                                        )),
                                    Text('Business'),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                            width: 56.0,
                                            height: 56.0,
                                            decoration: new BoxDecoration(
                                              color: Colors.purpleAccent,
                                              shape: BoxShape.circle,
                                            ),
                                            child: IconButton(
                                              icon: Icon(FontAwesomeIcons.laptopFile,color: colors.white), onPressed: () => loansDialog(context, 'ASSET'),
                                              color: colors.green,
                                            )),
                                        Text('Asset'),
                                      ],
                                    ),
                                  ],

                                ),
                                Row(
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                            width: 56.0,
                                            height: 56.0,
                                            decoration: new BoxDecoration(
                                              color: Colors.deepOrange,
                                              shape: BoxShape.circle,
                                            ),
                                            child: IconButton(
                                              icon: Icon(FontAwesomeIcons.graduationCap,color: colors.white), onPressed: () => loansDialog(context, 'SCHOOL_FEES'),
                                              color: colors.green,
                                            )),
                                        const Text('School Fees'),
                                      ],
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                            width: 56.0,
                                            height: 56.0,
                                            decoration: new BoxDecoration(
                                              color: colors.brightGreen,
                                              shape: BoxShape.circle,
                                            ),
                                            child: IconButton(
                                              icon: Icon(Icons.flash_on,color: colors.white), onPressed: () async => await Navigator.push(context, MaterialPageRoute(builder: (context)=> const FlashLoan())),
                                              color: colors.green,
                                            )),
                                        Text('Flash'),
                                      ],
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ),

                    ],
                  )
                ),
                SizedBox(height: 12.0,),
                Container(
                  // height: MediaQuery.of(context).size.height/3.5,
                  height: 150,
                  padding: EdgeInsets.all(12),
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(10),
                    // border: Border.all(color: colors.lightGrey, width: 1)
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Add Guarantor', style: TextStyle(fontWeight: FontWeight.bold),),
                          FutureBuilder(
                          future: countAppliedLoans(),
                          builder: (context, snapshot){
                          if(snapshot.hasData){
                          loans = snapshot.data;
                          if(loans!.isNotEmpty) {
                            return Container(
                                height: 20,
                                width: 20,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color: colors.deepOrange,
                                    borderRadius: BorderRadius.circular(10)
                                ),
                                child: Text('${loans?.length}',
                                    style: TextStyle(color: colors.white,
                                        fontWeight: FontWeight.bold))
                            );
                            }
                            }
                          return Text('');
                          }),

                        ],
                      ),
                      const Text('You can only get loans through guarantorship and therefore, you need to request your selected guarantors for consent and amount.',),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          RoundedButton(height:36, width:100, color: colors.green, onTap: (){
                            if(loans!.isNotEmpty) {
                              Navigator.push(context, MaterialPageRoute(
                                  builder: (context) => const GuaranteeLoan()));
                            }
                            else{
                              toast.showToast("You have not applied any loan to add guarantors.");
                            }
                            },
                            text: 'Open', borderRadius: BorderRadius.circular(18),)
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 12,),
                Container(
                  // height: MediaQuery.of(context).size.height/3.5,
                  height: 150,
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(10),
                      // border: Border.all(color: colors.lightGrey, width: 1)
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Guarantee Loans', style: TextStyle(fontWeight: FontWeight.bold),),
                          FutureBuilder(
                              future: fetchGuaranteedLoans(),
                              builder: (context, snapshot){
                                if(snapshot.hasData){
                                  guaranteedLoans = snapshot.data;
                                  if(guaranteedLoans!.isNotEmpty){
                                  return Container(
                                      height: 20,
                                      width: 20,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                          color: colors.deepOrange,
                                          borderRadius: BorderRadius.circular(10)
                                      ),
                                      child: Text('${guaranteedLoans?.length}',style: TextStyle(color:colors.white, fontWeight: FontWeight.bold))
                                  );
                                  }
                                }
                                return Text('');
                              }),
                        ],
                      ),
                      const Text('As a member, you have a responsibility of guaranteeing your trusted members for loans. However, you can consent or reject guaranteeing.',),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          RoundedButton(height:36, width:100, color: colors.green,
                            onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=> const UpdateGuaranteeAmount())), 
                            text: 'Open', borderRadius: BorderRadius.circular(18),)
                        ],
                      )
                    ],
                  ),
                ),
                SizedBox(height: 12,),

              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<dynamic> loansDialog(BuildContext context, loanType){
    return showDialog(
        context: context,
        builder: (context)=>AlertDialog(
          title: Text('Applying for ${loanType.toLowerCase()} loan', style: TextStyle(color: colors.green),),
          content: Form(
            key: _loanApplicationFormKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                NumericTextField(
                  controller: _loanAmountController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Amount cannot be empty';
                    }
                    return null;
                  },
                  hintText: 'Enter Amount',),
                const SizedBox(height: 12,),
                NumericTextField(
                  controller: _loanInstalmentController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter instalment';
                    }
                    return null;
                  },
                  hintText: 'Enter Instalments',)
              ],
            ),
          ),
          actions: [
            FlatTextButton(onPressed: (){
              Navigator.pop(context);
              _loanInstalmentController.clear();
              _loanAmountController.clear();
              }, text: 'CANCEL'),
            FlatTextButton(onPressed: ()=>loanApplication(context, loanType), text: 'SUBMIT')
          ],
        ));
  }

  Future<void> loanApplication(BuildContext context, category) async {
    if (_loanApplicationFormKey.currentState!.validate()) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var id = prefs.getString('id');
      // print(id);
      DateTime now = DateTime.now();
      var appl_date= DateFormat('yyyy-MM-dd').format(now).toString();
      // print(appl_date);
      LoansController loans = LoansController();
      var data = {
        "principal": _loanAmountController.text,
        "instalments": _loanInstalmentController.text,
        "memberId": id,
        "loanType": category,
        "interest": 2.0,
        "loanStatus": "REVIEW"
      };
      showDialog(
        context: context,
        builder: (context){
          return Center(
            child: CircularProgressIndicator(color: colors.green,),
          );
        },
      );
      Response res = await loans.postLoan(data);
      print(res.statusCode);
      Navigator.pop(context);
      if(res.statusCode == 201){
        Navigator.pop(context);
        toast.showToast('Application submitted successfully');
        Navigator.push(context, MaterialPageRoute(builder: (context)=>GuaranteeLoan()));
        _loanAmountController.clear();
        _loanInstalmentController.clear();
        setState(() {
          appliedLoans?.add(Loan());
        });

        // Navigator.of(context).pop();//redirect user to guarantor page where guarantors for the loan can be added.This can also be accessed through guarantorship card below
      }
      else{
        toast.showToast('Application failed. Check and try again');
        Navigator.of(context).pop();
      }
      // Navigator.of(context).pop();
  }
  }



}


