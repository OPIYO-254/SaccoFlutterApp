
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sojrel_sacco_client/components/toast.dart';
import 'package:sojrel_sacco_client/utils/colors.dart';

import '../components/buttons.dart';
import '../components/divider.dart';
import '../components/textfields.dart';
import '../models/member_model.dart';
import '../services/member_details_service.dart';

class FlashPaymentPage extends StatefulWidget {
  const FlashPaymentPage({super.key, required this.amount, required this.loanId});

  final double amount;
  final int loanId;

  @override
  State<FlashPaymentPage> createState() => _FlashPaymentPageState();
}
enum SingingCharacter { full, partial }

class _FlashPaymentPageState extends State<FlashPaymentPage> {
  MyColors colors = MyColors();
  final TextEditingController _amountController = TextEditingController();
  SingingCharacter? _character = SingingCharacter.full;
  String? phone_no;

  Future<Member>? _fetchMemberDetails() async {
    try {
      Member fetchedMember = await MemberDetails().fetchMemberDetails();
      phone_no = fetchedMember.phone;
      print(phone_no);
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
      rethrow;
    }
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchMemberDetails();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Payment", style: TextStyle(color: colors.white),),
        backgroundColor: colors.green,
      ),
      body: SingleChildScrollView(
        child: SizedBox(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  const SizedBox(height: 24.0,),
                  const Text('Payment Amount:', style: TextStyle(fontSize: 16),),
                  const SizedBox(height: 12,),
                  Text('Ksh ${widget.amount}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
                  const SizedBox(height: 12,),
                  MyDivider(),
                  Column(
                    children:[
                      ListTile(
                        title: const Text('Pay full amount'),
                        leading: Radio<SingingCharacter>(
                          value: SingingCharacter.full,
                          groupValue: _character,
                          onChanged: (SingingCharacter? value) {
                            setState(() {
                              _character = value;
                            });
                          },
                        ),
                      ),
                      ListTile(
                        title: const Text('Make partial payment'),
                        leading: Radio<SingingCharacter>(
                          value: SingingCharacter.partial,
                          groupValue: _character,
                          onChanged: (SingingCharacter? value) {
                            setState(() {
                              _character = value;

                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  _character == SingingCharacter.partial ? SizedBox(
                    width: MediaQuery.of(context).size.width/2.5,
                    height: 56,
                    child: NumericTextField(
                        controller: _amountController,
                        validator: (value){
                          if (value == null || value.isEmpty) {
                            return 'Amount cannot be empty';
                          }
                          return null;
                        },
                        hintText: 'Enter amount'
                    ),
                  ):const Text(''),

                  const SizedBox(height: 24,),
                  MyRaisedButton(
                    text: 'Make payment',
                    onTap: () async {
                      print(phone_no);
                      if(_character == SingingCharacter.full){
                        // MyToast().showToast(widget.amount.toString());
                        loanRepayment(widget.amount, widget.loanId);
                      }
                      else{
                        if(_amountController.text == ''){
                          MyToast().showToast("Please enter repayment amount");
                        }
                        else {
                          loanRepayment(_amountController.text, widget.loanId);
                        }
                      }
                    },
                  )
                ],
              ),
            )
        )
      ),
    );
  }

  Future<void> loanRepayment(amount, loanId) async {
    var data = {
      'loanId':loanId,
      'amount':amount
    };
    showDialog(
      context: context,
      builder: (context){
        return Center(
          child: CircularProgressIndicator(color: colors.green,),
        );
      },
    );
    MyToast().showToast(amount.text);
    //call repayment from service class



  }
}
