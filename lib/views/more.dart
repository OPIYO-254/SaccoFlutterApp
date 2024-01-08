import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sojrel_sacco_client/components/toast.dart';
import 'package:sojrel_sacco_client/utils/colors.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/member_model.dart';
import '../services/member_details_service.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MorePage extends StatefulWidget {
  const MorePage({
    super.key,
  });

  @override
  State<MorePage> createState() => _MorePageState();
}

class _MorePageState extends State<MorePage> {
  MyColors colors = MyColors();
  String? fname;
  String? mname;
  String? lname;
  String? id;
  Member? member;
  String? photoUrl;
  String _appVersion = '';

  // Future<void> _getAppVersion() async {
  //   PackageInfo packageInfo = await PackageInfo.fromPlatform();
  //   setState(() {
  //     _appVersion = packageInfo.version;
  //   });
  // }
  Future<Member> _fetchMemberDetails() async {
    try {
      Member memberDetails = await MemberDetails().fetchMemberDetails();
      // print(memberDetails.passportUrl);
      return memberDetails;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _launchUrl(url) async {
    final Uri uri = Uri(
      scheme: 'tel',
      path: url,
    );
    if (await canLaunchUrl(uri)) {
      try {
        await launchUrl(uri);
      } on PlatformException catch (e) {
        MyToast().showToast(e.toString());
        rethrow;
      }
    }
  }

  Future<void> _launchWeb(url) async {
    final Uri uri = Uri.https(url);
    // final Uri uri = Uri(
    //   scheme: 'https',
    //   path: url,
    // );
    if (await canLaunchUrl(uri)) {
      try {
        await launchUrl(uri);
      } on PlatformException catch (e) {
        MyToast().showToast(e.toString());
        rethrow;
      }
    }
  }

  String? encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((MapEntry<String, String> e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  Future<void> _launchEmail(url) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: url,
      query: encodeQueryParameters(<String, String>{
        'subject': 'Support and help',
      }),
    );
    try {
      await launchUrl(emailLaunchUri);
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> launchFacebook() async{
    final Uri uri = Uri.https('www.facebook.com', '/profile.php', {
      'id': '100095407398366',
      'mibextid': 'ZbWKwL',
    });
    try {
      bool launched = await launchUrl(uri, mode: LaunchMode.platformDefault);

      if (!launched) {
        launchUrl(uri);
      }
    } catch (e) {
      launchUrl(uri);
    }
  }
  Future<void> _launchInstagramIfInstalled() async {
//https://instagram.com/sojrelsacco?igshid=OGY3MTU3OGY1Mw==
    final Uri uri = Uri.https("www.instagram.com", "/sojrelsacco",
      {
        "igshid":"OGY3MTU3OGY1Mw=="
      });
    try {
      bool launched = await launchUrl(uri,
          mode: LaunchMode.platformDefault); // Launch the app if installed!

      if (!launched) {
        launchUrl(uri); // Launch web view if app is not installed!
      }
    } catch (e) {
      launchUrl(uri); // Launch web view if app is not installed!
    }
  }

  Future<void> _launchWhatsapp(String url) async {
    final Uri uri = Uri.parse("https://wa.me/$url");
    try {
      bool launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
      if (!launched) {
        launchUrl(uri);
      }
    } catch (e) {
      launchUrl(uri);
    }
  }

  String? token;

  Future<void>? getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString("token");
      // print(token);
    });
  }
  // Future<String?> getPhotoUrl() async{
  //   String? myUrl = await MemberDetails().getPhotoUrl();
  //   setState(() {
  //     photoUrl=myUrl;
  //   });
  //   // print(myUrl);
  //   return myUrl;
  // }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchMemberDetails();
    getToken();
    // _getAppVersion();
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
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: PhysicalModel(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(8),
                    elevation: 2,
                    child: Container(
                      height: 100,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 12),
                            child: FutureBuilder<Member>(
                              future: _fetchMemberDetails(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return CircularProgressIndicator(
                                    color: colors.green,
                                  );
                                } else if (snapshot.hasError) {
                                  // Navigator.pop(context);
                                  return const Text('Error');
                                } else {
                                  final cache = DefaultCacheManager();
                                  Member fetchedMember = snapshot.data!;
                                  fname = fetchedMember.firstName;
                                  mname = fetchedMember.midName;
                                  lname = fetchedMember.lastName;
                                  return fetchedMember.passportUrl != null ? CircleAvatar(
                                    radius: 36,
                                    foregroundImage:
                                        NetworkImage(fetchedMember.passportUrl!),
                                    child: Container(
                                      height: 72,
                                      width: 72,
                                      padding: const EdgeInsets.all(24.0),
                                      decoration: BoxDecoration(
                                          color: colors.green,
                                          borderRadius: BorderRadius.circular(36)),
                                      child: Center(
                                        child: Text(
                                            mname!.isNotEmpty
                                                ? fname![0] + mname![0]
                                                : fname![0] + lname![0],
                                            style: TextStyle(
                                                color: colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14)),
                                      ),
                                    ),
                                    // NetworkImage('https://img.freepik.com/free-photo/young-bearded-man-with-striped-shirt_273609-5677.jpg',),
                                  ):
                                  Container(
                                    height: 72,
                                    width: 72,
                                    padding: const EdgeInsets.all(24.0),
                                    decoration: BoxDecoration(
                                        color: colors.green,
                                        borderRadius: BorderRadius.circular(36)),
                                    child: Center(
                                      child: Text(
                                          mname!.isNotEmpty
                                              ? fname![0] + mname![0]
                                              : fname![0] + lname![0],
                                          style: TextStyle(
                                              color: colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14)),
                                    ),
                                  );
                                  // return Text(mname !='' ?'${fname![0]+mname![0]}': '${fname![0]+lname![0]}', style: TextStyle(color: colors.white, fontWeight: FontWeight.bold, fontSize: 24),);
                                }
                              },
                            ),
                            // (fname != null)?Text(mname !='' ?'${fname![0]+mname![0]}': '${fname![0]+lname![0]}', style: TextStyle(color: colors.white, fontWeight: FontWeight.bold, fontSize: 24),):CircularProgressIndicator(color: colors.white,),
                          ),
                          const SizedBox(
                            width: 12,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              FutureBuilder<Member>(
                                future: _fetchMemberDetails(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Text('Loading...');
                                  } else if (snapshot.hasError) {
                                    // Navigator.pop(context);
                                    return const Text('Error');
                                  } else {
                                    Member fetchedMember = snapshot.data!;
                                    fname = fetchedMember.firstName;
                                    mname = fetchedMember.midName;
                                    lname = fetchedMember.lastName;
                                    // ... (Update other properties as needed)
                                    return mname != ''
                                        ? Text(
                                            '$fname $mname $lname',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          )
                                        : Text(
                                            '$fname $lname',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          );
                                  }
                                },
                              ),
                              // (fname!=null)?:CircularProgressIndicator(color: colors.green,),
                              FutureBuilder<Member>(
                                future: _fetchMemberDetails(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Text('Loading...');
                                  } else if (snapshot.hasError) {
                                    // Navigator.pop(context);
                                    return const Text('Error');
                                  } else {
                                    Member fetchedMember = snapshot.data!;
                                    id = fetchedMember.id;
                                    fname = fetchedMember.firstName;
                                    mname = fetchedMember.midName;
                                    lname = fetchedMember.lastName;
                                    // ... (Update other properties as needed)
                                    return Text(
                                      id != null
                                          ? 'Member No. $id'
                                          : 'loading..',
                                      style:
                                          const TextStyle(fontWeight: FontWeight.bold),
                                    );
                                  }
                                },
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 4,
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height - 80,
                  child: ListView(
                    children: [
                      Card(
                        color: Theme.of(context).colorScheme.primary,
                        child: ListTile(
                            title: const Text('Membership'),
                            subtitle:
                                const Text('More information about membership'),
                            leading: const Icon(FontAwesomeIcons.users),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => membershipBottomSheet(context)),
                      ),
                      Card(
                        color: Theme.of(context).colorScheme.primary,
                        child: ListTile(
                            title: const Text('Contributions'),
                            subtitle:
                                const Text('More information on contributions'),
                            leading:
                                const Icon(FontAwesomeIcons.moneyCheckDollar),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => contributionsBottomSheet(context)),
                      ),
                      Card(
                        color: Theme.of(context).colorScheme.primary,
                        child: ListTile(
                            title: const Text('Services'),
                            subtitle: const Text(
                                'More information about our services'),
                            leading: const Icon(FontAwesomeIcons.listCheck),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => serviceBottomSheet(context)),
                      ),
                      Card(
                        color: Theme.of(context).colorScheme.primary,
                        child: ListTile(
                            title: const Text('Support'),
                            subtitle:
                                const Text('More information on our support'),
                            leading: const Icon(FontAwesomeIcons.headset),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => supportBottomSheet(context)),
                      ),
                      Card(
                        color: Theme.of(context).colorScheme.primary,
                        child: ListTile(
                            title: const Text('About Us'),
                            subtitle: const Text('More information about us'),
                            leading: const Icon(FontAwesomeIcons.circleInfo),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => aboutBottomSheet(context)),
                      ),
                      // Card(
                      //   child: ListTile(
                      //       title: const Text('Logout'),
                      //       subtitle: const Text(''),
                      //       leading: const Icon(Icons.power_settings_new),
                      //       trailing: const Icon(Icons.chevron_right),
                      //       onTap: () => logout(context)),
                      // ),
                      //   const SizedBox(
                      //   height: 240,
                      //   child: Row(
                      //     crossAxisAlignment: CrossAxisAlignment.start,
                      //     mainAxisAlignment: MainAxisAlignment.center,
                      //     children: [
                      //       Padding(
                      //         padding: EdgeInsets.symmetric(vertical: 12.0),
                      //         child: Text('version 1.0.0'),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }



  Future<dynamic> membershipBottomSheet(BuildContext context) {
    return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        isDismissible: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12), topRight: Radius.circular(12)),
        ),
        builder: (context) {
          return Container(
            height: MediaQuery.of(context).size.height / 1.1,
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.background,
                borderRadius: BorderRadius.circular(12.0)
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    // SizedBox(height: 18,),
                    Container(
                      height: 60,
                      width: MediaQuery.of(context).size.width,
                      // margin: EdgeInsets.symmetric(horizontal: 4),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: Theme.of(context).colorScheme.secondary,
                              width: 1.0)),
                      child: Text('Sacco Membership',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: colors.green)),
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 1.1 - 72,
                      child: ListView(
                        children: [
                          PhysicalModel(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Individual membership',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: colors.green),
                                      textAlign: TextAlign.start
                                  ),
                                  const Text(
                                    'The sacco membership is open to any individuals who meet the minumum requirements established by the sacco.\nRequirements for individual membership\nOne has to hold an national ID\nOne has to contribute a minimum of 10 shares equivalent of Ksh 10,000.\nOne must have be actively involved in the sacco activities.',
                                    textAlign: TextAlign.justify,
                                  )
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          PhysicalModel(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Group membership',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: colors.green),
                                      textAlign: TextAlign.start
                                  ),
                                  const Text(
                                    'The sacco membership is open to any individuals who meet the minumum requirements established by the sacco.\nRequirements for individual membership\nOne has to hold an national ID\nOne has to contribute a minimum of 10 shares equivalent of Ksh 10,000.\nOne must have be actively involved in the sacco activities.',
                                    textAlign: TextAlign.justify,
                                  )
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          PhysicalModel(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // crossAxisAlignment: CrossAxisAlignment.start,
                                  Text(
                                    'Corporate membership',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: colors.green),
                                      textAlign: TextAlign.start
                                  ),
                                  const Text(
                                    'The sacco membership is open to any individuals who meet the minumum requirements established by the sacco.\nRequirements for individual membership\nOne has to hold an national ID\nOne has to contribute a minimum of 10 shares equivalent of Ksh 10,000.\nOne must have be actively involved in the sacco activities.',
                                    textAlign: TextAlign.justify,
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  Future<dynamic> contributionsBottomSheet(BuildContext context) {
    return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        isDismissible: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12), topRight: Radius.circular(12)),
        ),
        builder: (context) {
          return Container(
            height: MediaQuery.of(context).size.height / 1.1,
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.background,
                borderRadius: BorderRadius.circular(12.0)
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    // SizedBox(height: 18,),
                    Container(
                      height: 60,
                      width: MediaQuery.of(context).size.width,
                      // margin: EdgeInsets.symmetric(horizontal: 4),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: Theme.of(context).colorScheme.secondary,
                              width: 1.0)),
                      child: Text('Member Contributions',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: colors.green)),
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 1.1 - 72,
                      child: ListView(
                        children: [
                          PhysicalModel(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Shares',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: colors.green),
                                      textAlign: TextAlign.start
                                  ),
                                  const Text(
                                      'This is a long term saving account. Shares earns dividends.\nThe shares are non-refundable but can be transferred to existing members \nShares can be purchased once or on monthly basis depending on the client choice \nThe minimum shares that a member should have is worth Ksh 10,000.',
                                      textAlign: TextAlign.justify
                                  )
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          PhysicalModel(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Savings',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: colors.green),
                                      textAlign: TextAlign.start
                                  ),
                                  const Text(
                                      'These are the continuous monthly savings that a member should make to the Sacco throughout their membership.\nSavings earns interest and allow members to access loans.\nSavings can be contributed through standing order, check off, mobile banking, bank transfer or the direct deposit.\nThe savings are only accessed upon the membership withdrawal',
                                      textAlign: TextAlign.start
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // SizedBox(height: 12,),
                  ],
                ),
              ),
            ),
          );
        });
  }

  Future<dynamic> serviceBottomSheet(BuildContext context) {
    return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        isDismissible: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12), topRight: Radius.circular(12)),
        ),
        builder: (context) {
          return Container(
            height: MediaQuery.of(context).size.height / 1.1,
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.background,
                borderRadius: BorderRadius.circular(12.0)
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    // const SizedBox(height: 18,),
                    Container(
                      height: 60,
                      width: MediaQuery.of(context).size.width,
                      // margin: EdgeInsets.symmetric(horizontal: 4),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: Theme.of(context).colorScheme.secondary,
                              width: 1.0)),
                      child: Text('Our Services',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: colors.green)),
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 1.1 - 72,
                      child: ListView(
                        children: [
                          PhysicalModel(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Short Term Loans',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: colors.green),
                                    ),
                                    const Text(
                                        'These are loans repayable within 3 months. They include: \nEmergency Loans \nFlash Loans')
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          PhysicalModel(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Mid Term Loans',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: colors.green),
                                    ),
                                    const Text(
                                        'These are loans repayable between 4 months and 1year. They include: \nNormal Loans \nJijenge Loans \nAsset Loans')
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          PhysicalModel(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Long Term Loans',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: colors.green),
                                    ),
                                    const Text(
                                        'These are loans repaid in more than 1 year. They include: \nDevelopment Loans \nSchool Fees Loan \nBusiness Loan')
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )

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
            ),
          );
        });
  }

  Future<dynamic> supportBottomSheet(BuildContext context) {
    return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        isDismissible: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12), topRight: Radius.circular(12)),
        ),
        builder: (context) {
          return Container(
            height: MediaQuery.of(context).size.height / 1.1,
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.background,
                borderRadius: BorderRadius.circular(12.0)
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Container(
                      height: 60,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: Theme.of(context).colorScheme.secondary,
                              width: 1.0)),
                      child: Text('Reach out to our support team',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: colors.green)),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 1.1 - 78,
                      child: ListView(
                        scrollDirection: Axis.vertical,
                        children: [
                          const SizedBox(
                            height: 8,
                          ),
                          Card(
                            color: Theme.of(context).colorScheme.primary,
                            child: ListTile(
                                title: const Text('(0)729-856-604'),
                                subtitle: const Text('Call'),
                                leading: const Icon(
                                  Icons.phone,
                                  color: Colors.green,
                                ),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () async =>
                                    await _launchUrl('+254729856604')),
                          ),

                          Card(
                            color: Theme.of(context).colorScheme.primary,
                            child: ListTile(
                                title: const Text('(0)750-633-766'),
                                subtitle: const Text('Call'),
                                leading: const Icon(
                                  Icons.phone,
                                  color: Colors.green,
                                ),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () async =>
                                    await _launchUrl('+254750633766')),
                          ),

                          Card(
                            color: Theme.of(context).colorScheme.primary,
                            child: ListTile(
                                title: const Text('(0)718-742-925'),
                                subtitle: const Text('Call'),
                                leading: const Icon(
                                  Icons.phone,
                                  color: Colors.green,
                                ),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () async =>
                                    await _launchUrl('+254718742925')),
                          ),

                          Card(
                            color: Theme.of(context).colorScheme.primary,
                            child: ListTile(
                              title: const Text('sojrelsaccomanager@gmail.com'),
                              subtitle: const Text('Email us'),
                              leading: const Icon(
                                Icons.email_outlined,
                                color: Colors.redAccent,
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () async => await _launchEmail(
                                  'sojrelsaccomanager@gmail.com'),
                            ),
                          ),

                          Card(
                            color: Theme.of(context).colorScheme.primary,
                            child: ListTile(
                              title: const Text('www.sojrelsacco.com'),
                              subtitle: const Text('Visit our website'),
                              leading: const Icon(
                                FontAwesomeIcons.earthAfrica,
                                color: Colors.lightBlueAccent,
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () async =>
                                  await _launchWeb('sojrelsacco.com'),
                            ),
                          ),

                          Card(
                            color: Theme.of(context).colorScheme.primary,
                            child: ListTile(
                              title: const Text('Facebook'),
                              subtitle: const Text('Visit our page'),
                              leading: const Icon(
                                Icons.facebook,
                                color: Colors.blueAccent,
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () async => await launchFacebook(),
                            ),
                          ),
                          Card(
                            color: Theme.of(context).colorScheme.primary,
                            child: ListTile(
                              title: const Text('Instagram'),
                              subtitle: const Text('Visit our page'),
                              leading: const Icon(
                                FontAwesomeIcons.instagram,
                                color: Colors.purpleAccent,
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () async => await _launchInstagramIfInstalled(),
                            ),
                          ),


                          Card(
                            color: Theme.of(context).colorScheme.primary,
                            child: ListTile(
                              title: const Text('0750633766'),
                              subtitle: const Text('Whatsapp'),
                              leading: const Icon(
                                FontAwesomeIcons.whatsapp,
                                color: Colors.green,
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () async =>
                                  await _launchWhatsapp('+254750633766'),
                            ),
                          ),

                          const SizedBox(
                            height: 60,
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  Future<dynamic> aboutBottomSheet(BuildContext context) {
    return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        isDismissible: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12), 
              topRight: Radius.circular(12)),
        ),
        builder: (context) {
          return Container(
            height: MediaQuery.of(context).size.height / 1.1,
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.background,
              borderRadius: BorderRadius.circular(12.0)
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    // const SizedBox(height: 12,),
                    Container(
                      height: 60,
                      width: MediaQuery.of(context).size.width,
                      // margin: EdgeInsets.symmetric(horizontal: 4),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: Theme.of(context).colorScheme.secondary,
                              width: 1.0)),
                      child: Text('About Sojrel Sacco',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: colors.green)),
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 1.1 - 72,
                      child: ListView(
                        children: [
                          PhysicalModel(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Our beginnings',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: colors.green),
                                  ),
                                  const Text(
                                    'Sojrel Sacco, is your trusted partner on the path to financial success. Established in 2021, we are a member-owned financial institution dedicated to helping individuals like you achieve your financial goals. The society was founded with a clear mission in mind: To uplift life in the society through provision of affordable financial services and ideas.',
                                    textAlign: TextAlign.justify,
                                  )
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          PhysicalModel(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Our Core Values',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: colors.green),
                                    ),
                                    const Text(
                                      'Integrity:',
                                    ),
                                    const Text('Accountability'),
                                    const Text('Transparency'),
                                    const Text('Customer Focus'),
                                    const Text('Objectivity'),
                                    const Text('Proactivity')
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          PhysicalModel(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Vision and Mission',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: colors.green),
                                  ),
                                  const Text(
                                      'Our Vision:\nTo be Kenya’s most society-oriented financial provider.'),
                                  const Text(
                                      'Our Mission:\nTo uplift life in the society through provision of affordable financial services and ideas.')
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 48,
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
