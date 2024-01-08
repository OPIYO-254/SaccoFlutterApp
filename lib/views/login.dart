// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sojrel_sacco_client/components/divider.dart';
import 'package:sojrel_sacco_client/components/toast.dart';
import 'package:sojrel_sacco_client/views/signup.dart';
import '../components/buttons.dart';
import '../controller/auth_controller.dart';
import '../utils/colors.dart';

import '../components/textfields.dart';
import 'nav.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();

}

class _LoginPageState extends State<LoginPage> {
  MyColors colors = MyColors();
  MyToast toast = MyToast();
  final _loginFormKey = GlobalKey<FormState>();
  final _resetPasswordFormKey = GlobalKey<FormState>();
  final emailFieldController = TextEditingController();
  final passwordFieldController = TextEditingController();
  final _resetEmailFieldController = TextEditingController();

  bool isLoading = false;

  bool _obscureText = true;

  late bool userHasTouchId;
  final bool _useTouchId = false;
  final LocalAuthentication auth = LocalAuthentication();
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  Future<bool> canAuthenticate() async {
    bool canAuth = false;
    if(Platform.isAndroid) {
      canAuth = await auth.canCheckBiometrics;
    }
    return canAuth;
  }

  Future<bool> authenticate() async{
    try{
      if(!await canAuthenticate()) return false;
      return await auth.authenticate(localizedReason: "Authenticate to login");
    }
    catch (e){
      print(e.toString());
      return false;
    }
  }


  void getSecureStorage() async {
    final isUsingBio = await storage.read(key: 'usingBiometric');
    setState(() {
      userHasTouchId = isUsingBio == 'true';
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSecureStorage();

  }



  Future<void> userLogin(email, password) async {
    var data = {
      'email': email,
      'password': password
    };
    if (_loginFormKey.currentState!.validate()) {
      try {
        showDialog(
          context: context,
          builder: (context){
            return Center(
              child: CircularProgressIndicator(color: colors.green,),
            );
          },
        );
        var res = await AuthApi().postUser(data, '/login');
        Map<String, dynamic> jsonData = jsonDecode(res.body);
        String status = jsonData['status'];
        String message = jsonData['message'];
        if (status == 'success') {
          Navigator.of(context).pop();
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => NavPage(
                userEmail: email,
                wantsTouchId: _useTouchId,
                userPassword: password,)));
          toast.showToast(message);
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('token', jsonData['token']) ?? '';
          prefs.setString("id", jsonData['id']);
          emailFieldController.clear();
          passwordFieldController.clear();
          isLoading = false;
          //
        }
        else {
          toast.showToast(message);
          Navigator.of(context).pop();
        }
      }
      catch (e){
        toast.showToast("No connection to the server");
        Navigator.of(context).pop();
      }
    }

  }

  Future<void> biometricUserLogin(email, password) async {
    var data = {
      'email': email,
      'password': password
    };

    try {
      showDialog(
        context: context,
        builder: (context){
          return Center(
            child: CircularProgressIndicator(color: colors.green,),
          );
        },
      );
      var res = await AuthApi().postUser(data, '/login');
      Map<String, dynamic> jsonData = jsonDecode(res.body);
      String status = jsonData['status'];
      String message = jsonData['message'];
      if (status == 'success') {
        Navigator.of(context).pop();
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => NavPage(
          userEmail: email,
          wantsTouchId: _useTouchId,
          userPassword: password,)));
        toast.showToast(message);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('token', jsonData['token']) ?? '';
        prefs.setString("id", jsonData['id']);
        emailFieldController.clear();
        passwordFieldController.clear();
        isLoading = false;
        //
      }
      else {
        toast.showToast(message);
        Navigator.of(context).pop();
      }
    }
    catch (e){
      toast.showToast("No connection to the server");
      Navigator.of(context).pop();
    }


  }


  @override
  Widget build(BuildContext context) {
    DateTime dateTimeBackPressed = DateTime.now();
    return WillPopScope(
      onWillPop: () async{
        final diff = DateTime.now().difference(dateTimeBackPressed);
        final isExitingWarning = diff >= const Duration(seconds: 2);
        dateTimeBackPressed = DateTime.now();
        if(isExitingWarning){
          MyToast().showToast("Press again to exit");
          return false;
        }
        else{
          return true;
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Form(
                  key: _loginFormKey,
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height,
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
                        const SizedBox(height: 24,),
                        Text('Login', style: TextStyle(color: colors.green,fontSize: 18, fontWeight: FontWeight.bold),),
                        const SizedBox(height: 12,),
                        MyTextFormField(
                          fieldController: emailFieldController,
                          validatorText: 'Email cannot be empty',
                          hintText: 'Enter email',
                          obscureText: false,
                          iconColor: Theme.of(context).colorScheme.secondary,
                          prefixIcon: const Icon(Icons.email_outlined, size: 20,),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 12,),
                        MyTextFormField(
                          fieldController: passwordFieldController,
                          validatorText: 'You must enter password',
                          hintText: 'Enter password',
                          obscureText: _obscureText,
                          iconColor: Theme.of(context).colorScheme.secondary,
                          prefixIcon: const Icon(Icons.lock_outline, size: 20,),
                          keyboardType: TextInputType.text,
                          suffixIcon: GestureDetector(
                            onTap: (){
                              setState(() {
                                _obscureText = !_obscureText;
                              });
                            },
                            child: Icon(_obscureText ? Icons.visibility: Icons.visibility_off),
                          )
                        ),
                        SizedBox(height: 12,),
                        FlatTextButton(
                          onPressed: ()=>showResetDialog(context),
                          text: 'Forgot password?',
                        ),
                        SizedBox(height: 12,),
                        MyRaisedButton(
                          text: 'Login',
                          onTap: ()=>userLogin(emailFieldController.text, passwordFieldController.text),

                        ),
                        const SizedBox(height: 16,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SizedBox(
                              height: 2,
                                width: MediaQuery.of(context).size.width/2.3,
                                child: MyDivider()),
                            const Text('OR'),
                            SizedBox(
                              height: 2,
                                width: MediaQuery.of(context).size.width/2.3,
                                child: MyDivider()),
                          ],
                        ),
                        const SizedBox(height: 16,),
                        GestureDetector(
                          onTap:() async{
                            bool auth = await authenticate();
                            if(auth){
                              // print('can authenticate $auth');
                              final userStoredEmail = await storage.read(key: 'email');
                              final userStoredPassword = await storage.read(key: 'password');
                              biometricUserLogin(userStoredEmail, userStoredPassword);
                            }
                          },
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              border: Border.all(color: colors.green, style: BorderStyle.solid),
                              borderRadius: BorderRadius.circular(8)
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.fingerprint_rounded, color: colors.green,),
                                Text('Use Touch ID', style: TextStyle(color: colors.green, fontWeight: FontWeight.bold),)
                              ],
                            ),
                          ),
                        ),
                        FlatTextButton(
                          onPressed: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>SingupPage())),
                          text: "Don't have account?",
                        ),
                        // SizedBox(height: 12,),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future showResetDialog(BuildContext context){
    return showDialog(
        context: context,
        builder: (context)=>AlertDialog(
          title: const Text('Reset Password'),
          content: Form(
            key: _resetPasswordFormKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 16,),
                MyTextFormField(
                    keyboardType: TextInputType.emailAddress,
                    fieldController: _resetEmailFieldController,
                    validatorText: 'You must provide your email',
                    hintText: 'Enter your email',
                    obscureText: false,
                    iconColor: Theme.of(context).colorScheme.secondary,
                    prefixIcon: const Icon(Icons.email_outlined))
              ],
            ),
          ),
          actions: [
            FlatTextButton(
                onPressed: ()=>Navigator.pop(context),
                text: 'CLOSE'),
            FlatTextButton(
                onPressed: ()=>resetPassword(context),
                text: 'SEND')
          ],
        )
    );
  }

  Future<void> resetPassword(BuildContext context) async{
    // var data = {"email":};
    if (_resetPasswordFormKey.currentState!.validate()) {
      showDialog(
        context: context,
        builder: (context){
          return Center(
            child: CircularProgressIndicator(color: colors.green,),
          );
        },
      );
      try {
        Response res = await AuthApi().resetPassword(
            _resetEmailFieldController.text, "/forgot-password");
        var jsonData = jsonDecode(res.body.trim());
        var message = jsonData['message'];
        var status = jsonData['status'];
        if (status == "success") {
          MyToast().showToast(message);
          _resetEmailFieldController.clear();
          Navigator.pop(context);
        }
        else {
          MyToast().showToast(jsonData['error']);
          _resetEmailFieldController.clear();
          Navigator.pop(context);
        }
      }
      catch(e){
        Navigator.pop(context);
        rethrow;
      }
    }
  }

}


