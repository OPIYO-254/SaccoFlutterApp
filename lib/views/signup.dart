import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sojrel_sacco_client/utils/colors.dart';

import '../components/buttons.dart';
import '../components/textfields.dart';
import '../components/toast.dart';
import '../controller/auth_controller.dart';
import 'login.dart';

class SingupPage extends StatefulWidget {
  const SingupPage({super.key});

  @override
  State<SingupPage> createState() => _SingupPageState();
}

class _SingupPageState extends State<SingupPage> {
  MyColors colors = MyColors();
  MyToast toast = MyToast();
  final _signupFormKey = GlobalKey<FormState>();
  final _emailTextController = TextEditingController();
  final _passwordFieldController = TextEditingController();
  final _cpasswordFieldController = TextEditingController();
  final _nameTextController = TextEditingController();

  bool _obscureTextP = true;
  bool _obscureTextCp = true;

  Future<void> userSignup() async {
    var data = {
      'name':_nameTextController.text,
      'email': _emailTextController.text,
      'password': _passwordFieldController.text
    };
    if (_signupFormKey.currentState!.validate()) {
      showDialog(
        context: context,
        builder: (context){
          return Center(
            child: CircularProgressIndicator(color: colors.green,),
          );
        },
      );
      if(_passwordFieldController.text == _cpasswordFieldController.text){
        var res = await AuthApi().postUser(data, '/signup');
        // Decode the JSON string into a Map
        Map<String, dynamic> jsonData = jsonDecode(res.body);
        // Access the keys and values
        String message = jsonData['message'];
        String status = jsonData['status'];
        if(status=='success'){
          // Navigator.pop(context);
          Navigator.push(context, MaterialPageRoute(builder: (context)=>LoginPage()));
          toast.showToast(message);
          _emailTextController.clear();
          _passwordFieldController.clear();
          _cpasswordFieldController.clear();
          _nameTextController.clear();
        }
        else{
          toast.showToast(message);
          _emailTextController.clear();
          _passwordFieldController.clear();
          _cpasswordFieldController.clear();
          _nameTextController.clear();
          Navigator.of(context).pop();
        }
      }
      else{
        toast..showToast('Passwords do not match');
        Navigator.of(context).pop();
      }

    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                key: _signupFormKey,
                child: SizedBox(
                  height:MediaQuery.of(context).size.height,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      PhysicalModel(
                        elevation: 6,
                        shadowColor: Theme.of(context).colorScheme.secondary,
                        borderRadius: BorderRadius.circular(60),
                        color: Theme.of(context).colorScheme.primary,
                        child: Container(
                          height: MediaQuery.of(context).size.height/10,
                          width: MediaQuery.of(context).size.height/10,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(60),
                              color: Theme.of(context).colorScheme.primary
                          ),
                          child: Image.asset('lib/images/log.png'),
                        ),
                      ),
                      SizedBox(height: 24,),
                      Text('Create Account', style: TextStyle(color: colors.green, fontSize: 18, fontWeight: FontWeight.bold),),
                      SizedBox(height: 24,),
                      MyTextFormField(
                        fieldController: _nameTextController,
                        validatorText: 'Name cannot be empty',
                        hintText: 'Enter your name',
                        obscureText: false,
                        iconColor: Theme.of(context).colorScheme.secondary,
                        keyboardType: TextInputType.name,
                        prefixIcon: Icon(Icons.account_circle_outlined, size: 20,),
                      ),
                      SizedBox(height: 24,),
                      MyTextFormField(
                        fieldController: _emailTextController,
                        validatorText: 'Email cannot be empty',
                        hintText: 'Enter email',
                        obscureText: false,
                        iconColor: Theme.of(context).colorScheme.secondary,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icon(Icons.email_outlined, size: 20,),
                      ),
                      SizedBox(height: 24,),
                      MyTextFormField(
                        fieldController: _passwordFieldController,
                        validatorText: 'You must enter password',
                        hintText: 'Enter password',
                        obscureText: _obscureTextP,
                        iconColor: Theme.of(context).colorScheme.secondary,
                        prefixIcon: Icon(Icons.lock_outline, size: 20,),
                        keyboardType: TextInputType.text,
                        suffixIcon: GestureDetector(
                          onTap: (){
                            setState(() {
                              _obscureTextP = !_obscureTextP;
                            });
                          },
                          child: Icon(_obscureTextP ? Icons.visibility: Icons.visibility_off),
                        )
                      ),
                      SizedBox(height: 24,),
                      MyTextFormField(
                        fieldController: _cpasswordFieldController,
                        validatorText: 'You must confirm password',
                        hintText: 'Confirm password',
                        obscureText: _obscureTextCp,
                        iconColor: Theme.of(context).colorScheme.secondary,
                        prefixIcon: Icon(Icons.lock_outline, size: 20,),
                        keyboardType: TextInputType.text,
                        suffixIcon: GestureDetector(
                          onTap: (){
                            setState(() {
                              _obscureTextCp = !_obscureTextCp;
                            });
                          },
                          child: Icon(_obscureTextCp ? Icons.visibility: Icons.visibility_off),
                        )
                      ),
                      SizedBox(height: 24,),
                      MyRaisedButton(
                        text: 'Signup',
                        onTap: ()=>userSignup(),
                      ),
                      FlatTextButton(
                        onPressed: ()=>Navigator.pop(context),
                        text: "Already have account?",
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
