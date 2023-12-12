
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sojrel_sacco_client/components/divider.dart';
import 'package:sojrel_sacco_client/components/toast.dart';
import 'package:sojrel_sacco_client/utils/colors.dart';

import '../components/buttons.dart';
import '../components/textfields.dart';
import '../controller/loans_controller.dart';
import '../models/loan_model.dart';
import '../models/member_model.dart';
import '../services/loans_service.dart';
import '../services/member_details_service.dart';

class UpdateGuaranteeAmount extends StatefulWidget {
  const UpdateGuaranteeAmount({super.key});

   @override
  State<UpdateGuaranteeAmount> createState() => _UpdateGuaranteeAmount();
}

class _UpdateGuaranteeAmount extends State<UpdateGuaranteeAmount> {
  final _guaranteeFormKey = GlobalKey<FormState>();
  final _guaranteeAmountController = TextEditingController();
  MyColors colors = MyColors();
  // SharedPreferences? prefs;
  String? guarantorId;
  List<Loan>? guaranteedLoans;
  // String? fname;
  // String? mname;
  // String? lname;
  SharedPreferences? prefs;

  Future<List<Loan>> fetchGuaranteedLoans() async{
    prefs = await SharedPreferences.getInstance();
    guarantorId = prefs?.getString("id");
    Member member = await MemberDetails().fetchMemberDetails();
    List<Loan>? allLoans = await LoansService().getAllLoans();
    List<Loan>? guaranteedLoans = member.loansGuaranteed;
    List<Loan> appliedLoans = [];
    guaranteedLoans?.forEach((e) {
      allLoans?.forEach((i) {
        if(e.id == i.id){
          if(i.loanStatus == 'REVIEW'){
            appliedLoans.add(i);

          }
        }
      });
    });
    return appliedLoans;
  }



  @override
  initState() {
    // TODO: implement initState
    super.initState();
    // fetchGuaranteedLoans();

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text('Guarantee Loan', style: TextStyle(color: colors.white),),
        backgroundColor: colors.green,
        elevation: 2,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: [
                const SizedBox(height: 12,),
                // SizedBox(
                //     height: 24,
                //     child: Text('Guarantee a Loan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: colors.green),)
                // ),
                Expanded(
                    child: FutureBuilder(
                      future: fetchGuaranteedLoans(),
                      builder: (context, snapshot){
                        if(snapshot.hasData){
                          guaranteedLoans = snapshot.data;
                          return ListView.builder(
                            itemCount: guaranteedLoans == null? 0: guaranteedLoans!.length,
                            itemBuilder: (BuildContext context, int index){
                              Loan? loan = guaranteedLoans?[index];
                              return Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      margin: const EdgeInsets.symmetric(horizontal: 4),
                                      height: 220,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.primary,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            // mainAxisAlignment: MainAxisAlignment.,
                                            children: [
                                              SizedBox(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    const Text('Applicant:'),
                                                    const SizedBox(height: 8,),
                                                    Text('${loan!.memberId} ${loan.borrowerFname} ${loan.borrowerMname} ${loan.borrowerLname}',
                                                        style: const TextStyle(fontSize: 14.0,fontWeight: FontWeight.bold)),
                                                  ],
                                                ),
                                              ),

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
                                                    const Text('Loan:'),
                                                    const SizedBox(height: 8,),
                                                    Text('#${loan.id} (${loan.loanType})',
                                                        style: const TextStyle(fontSize: 14.0,fontWeight: FontWeight.bold)),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.end,
                                                  children: [
                                                    const Text('Date Applied:'),
                                                    const SizedBox(height: 8,),
                                                    Text(DateFormat.yMMMEd().format(DateTime.parse(loan.applicationDate!)),
                                                        style: const TextStyle(fontSize: 14.0,fontWeight: FontWeight.bold)),
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
                                                    const Text('Amount Applied:'),
                                                    const SizedBox(height: 8,),
                                                    Text('Ksh ${loan.principal}',
                                                      style: const TextStyle(fontSize: 14.0,fontWeight: FontWeight.bold),),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.end,
                                                  children: [
                                                    const Text('Instalments:'),
                                                    Text('${loan.instalments} Months',style: const TextStyle(fontSize: 14.0,fontWeight: FontWeight.bold)),
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
                                                  child: RoundedButton(text: "Exit", onTap: ()=>{
                                                    Navigator.pop(context)
                                                  }, color: colors.deepOrange, width: 100, height: 36, borderRadius: BorderRadius.circular(18),)),
                                              const SizedBox(width: 24,),
                                              SizedBox(
                                                  child: RoundedButton(text: "Guarantee", onTap: ()=> guaranteeDialog(context,loan.id, guarantorId), 
                                                    color: colors.green, width: 100, height: 36, borderRadius: BorderRadius.circular(18),)
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12,),
                                ],
                              );
                            },
                          );
                        }
                        return Center(
                            child: SizedBox(
                                width: 46,
                                height: 46,
                                child: CircularProgressIndicator(color: colors.green,)
                            )
                        );
                      },
                    )
                ),
              ],
            )   ,
        ),
      ),
    )
    );
  }

  Future<dynamic> guaranteeDialog(BuildContext context, loanId, guarantorId){
    return showDialog(
        context: context,
        builder: (context)=>AlertDialog(
          title: Text('Guarantee loan', style: TextStyle(color: colors.green),),
          content: Form(
            key: _guaranteeFormKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                NumericTextField(
                  controller: _guaranteeAmountController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Amount cannot be empty';
                    }
                    return null;
                  },
                  hintText: 'Enter Amount',),
              ],
            ),
          ),
          actions: [
            FlatTextButton(
                onPressed: (){
              Navigator.pop(context);
              _guaranteeAmountController.clear();
            }, text: 'CANCEL'),
            FlatTextButton(
                onPressed: ()=>guaranteeLoan(context, loanId, guarantorId, _guaranteeAmountController.text),
                text: 'SEND')
          ],
        ));
  }

  Future<void> guaranteeLoan(BuildContext context, loanId, guarantorId, amount) async{
    if (_guaranteeFormKey.currentState!.validate()) {
      showDialog(
        context: context,
        builder: (context){
          return Center(
            child: CircularProgressIndicator(color: colors.green,),
          );
        },
      );
      try {

        var res = await LoansController().addGuaranteeAmount(
            loanId.toString(), guarantorId, amount.toString());
        // print('sending..');
        // print(res.body);
        var jsonData = jsonDecode(res.body.trim());
        if(res.statusCode==200){
          var jsonData = jsonDecode(res.body.trim());
          if (jsonData['status'] == 'success') {
            MyToast().showToast(jsonData['message']);
            _guaranteeAmountController.clear();
            Navigator.of(context).pop();
          }
          else {
            MyToast().showToast(jsonData['message']);
            _guaranteeAmountController.clear();
            Navigator.of(context).pop();
          }
        }
      }
      catch(e){
        MyToast().showToast(e.toString());
        print(e.toString());
      }
      finally{
        Navigator.of(context).pop();
      }
    }
  }





}
