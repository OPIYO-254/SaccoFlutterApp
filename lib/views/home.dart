
import 'dart:developer';

import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:sojrel_sacco_client/components/buttons.dart';
import 'package:sojrel_sacco_client/components/divider.dart';
import 'package:sojrel_sacco_client/services/members_service.dart';
import 'package:sojrel_sacco_client/utils/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sojrel_sacco_client/views/login.dart';

import '../models/contribution_model.dart';
import '../models/member_model.dart';
import '../services/member_details_service.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});


  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  MyColors colors = MyColors();
  String? token;
  String? email;
  String? fname;
  String? mname;
  String? lname;
  String? id;
  List<dynamic>? contributions;
  Map<String, dynamic>? contribution;
  int? total;
  int? savings;
  int? shares;
  String? greetings;
  List<Contribution>? contributionList;
  List<Member>? membersList;
  late Future<Member> member;
  bool _isVisible=true;
  bool _isVisibleShare=true;
  bool _isVisibleSaving=true;
  // final _navKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadUserData();
    member = _fetchMemberDetails()!;
    // _getGreeting();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('token'); // Retrieve token from SharedPreferences
      email = prefs.getString('email'); // Retrieve email from SharedPreferences
    });
  }

  String? _getGreeting(firstName) {
    DateTime now = DateTime.now();
    int hour = now.hour;
    if (hour >= 5 && hour < 12) {
      greetings = 'Good Morning, $firstName';
    } else if (hour >= 12 && hour < 17) {
      greetings = 'Good Afternoon, $firstName';
    } else if (hour >= 17 && hour < 20) {
      greetings = 'Good Evening, $firstName';
    } else {
      greetings = 'Good Night, $firstName';
    }
    return greetings;
  }

  Future<Member>? _fetchMemberDetails() async {
    try {
      Member fetchedMember = await MemberDetails().fetchMemberDetails();
      SharedPreferences prefs = await SharedPreferences.getInstance();
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


  Future<List<Contribution>?> getMemberContributions() async {
    Member member = await MemberDetails().fetchMemberDetails();
    return member.contributions;

  }
  Future<List<Member>?> getAllMembers() async {
    return await MemberService().fetchMembers();
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 8,
                ),
                Container(
                  alignment: Alignment.center,
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                      color: colors.green,
                      borderRadius: BorderRadius.circular(60)),
                  child: FutureBuilder<Member>(
                    future: _fetchMemberDetails(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator(
                          color: colors.white,
                        );
                      } else if (snapshot.hasError) {
                        // Navigator.pop(context);
                        return Text('Error!');
                      } else {
                        Member fetchedMember = snapshot.data!;
                        fname = fetchedMember.firstName;
                        mname = fetchedMember.midName;
                        lname = fetchedMember.lastName;
                        // ... (Update other properties as needed)

                        return Text(
                          mname != ''
                              ? '${fname![0] + mname![0]}'
                              : '${fname![0] + lname![0]}',
                          style: TextStyle(
                              color: colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 24),
                        );
                      }
                    },
                  ),
                ),
                SizedBox(height: 12,),
                SizedBox(
                  child: FutureBuilder<Member>(
                    future: _fetchMemberDetails(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Text('Loading...');
                      } else if (snapshot.hasError) {
                        return const Text('Error');
                      } else {
                        Member fetchedMember = snapshot.data!;
                        fname = fetchedMember.firstName;
                        mname = fetchedMember.midName;
                        lname = fetchedMember.lastName;
                        // ... (Update other properties as needed)
                        return (fname != null)?Text('${_getGreeting(fname)}',style: TextStyle(color: colors.green, fontWeight: FontWeight.bold, fontSize: 16)):const Text('Loading...');
                      }
                    },
                  ),
                ),

                const SizedBox(height: 12,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: PhysicalModel(
                    elevation: 2,
                    color: Theme.of(context).colorScheme.primary,
                    shadowColor: Theme.of(context).colorScheme.secondary,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      height: 120,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Total Contributions', style: TextStyle(color:Theme.of(context).colorScheme.tertiary),),
                              GestureDetector(onTap: (){
                                setState(() {
                                  _isVisible = !_isVisible;
                                });
                              }, child:
                                  Icon(_isVisible ? Icons.visibility_off : Icons.visibility, color: Theme.of(context).colorScheme.secondary,size: 24,))
                            ],
                          ),
                          Visibility(
                              visible: _isVisible,
                            child: FutureBuilder<Member>(
                              future: _fetchMemberDetails(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const Text('Loading...');
                                }
                                else if (snapshot.hasError) {
                                  return const Text('Error');

                                }
                                else {
                                  Member fetchedMember = snapshot.data!;
                                  total = fetchedMember.totalContributions;
                                  // ... (Update other properties as needed)
                                  return Text(total!=null ? 'Ksh ${total}':'loading..', style: TextStyle(color: Theme.of(context).colorScheme.tertiary, fontWeight: FontWeight.bold),);
                                }
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: SizedBox(
                    height: 120,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Container(
                            width: 240,
                            decoration: BoxDecoration(
                              color: colors.green,
                              borderRadius: BorderRadius.circular(10)
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                  Text('Savings',style: TextStyle(color: colors.white)),
                                  GestureDetector(onTap: (){
                                    setState(() {
                                      _isVisibleSaving = !_isVisibleSaving;
                                    });
                                  }, child:
                                  Icon(_isVisibleSaving ? Icons.visibility_off : Icons.visibility, color: colors.white,size: 24,))
                                ],),
                                Visibility(
                                  visible: _isVisibleSaving,
                                  child: FutureBuilder<Member>(
                                    future: _fetchMemberDetails(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return Text('Loading...', style: TextStyle(color: colors.white));
                                      } else if (snapshot.hasError) {
                                        return Text('Error');
                                      } else {
                                        Member fetchedMember = snapshot.data!;
                                        savings = fetchedMember.totalSavings;
                                        // ... (Update other properties as needed)
                                        return Text(savings!=null?"Ksh ${savings}":'loading..',style: TextStyle(color: colors.white, fontWeight: FontWeight.bold));
                                      }
                                    },
                                  ),
                                )
                                  // child:
                              ],
                            )
                          ),
                          SizedBox(width: 12,),
                          Container(
                            width: 240,
                            decoration: BoxDecoration(
                                color: colors.green,
                                borderRadius: BorderRadius.circular(10)
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Shares',style: TextStyle(color: colors.white)),
                                    GestureDetector(onTap: (){
                                      setState(() {
                                        _isVisibleShare = !_isVisibleShare;
                                      });
                                    }, child:
                                    Icon(_isVisibleShare ? Icons.visibility_off : Icons.visibility, color: colors.white,size: 24,))
                                  ],
                                ),
                                Visibility(
                                    visible: _isVisibleShare,
                                  child: FutureBuilder<Member>(
                                    future: _fetchMemberDetails(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return Text('Loading...', style: TextStyle(color: colors.white),);
                                      } else if (snapshot.hasError) {
                                        return const Text('Error');
                                      } else {
                                        Member fetchedMember = snapshot.data!;
                                        shares = fetchedMember.totalShares;
                                        // ... (Update other properties as needed)
                                        return Text(shares!=null?'Ksh ${shares}':'loading..',style: TextStyle(color: colors.white, fontWeight: FontWeight.bold));
                                      }
                                    },
                                  ),
                                ) // child:

                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12,),
                Card(
                  color: Theme.of(context).colorScheme.primary,
                  elevation: 4,
                  child: Container(
                    height: 130,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Contribution History', style: TextStyle(color: Theme.of(context).colorScheme.tertiary, fontWeight: FontWeight.bold),),
                        Text('View your sacco contribution history',style: TextStyle(color: Theme.of(context).colorScheme.tertiary)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            RoundedButton(
                              color: colors.green,
                              onTap: () => contributionsBottomSheet(context),
                              text: 'View',
                              width: 100,
                              height: 36, borderRadius: BorderRadius.circular(18),)
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 12,),
                Card(
                  color: Theme.of(context).colorScheme.primary,
                  elevation: 4,
                  child: Container(
                    height: 130,
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Sacco Members', style: TextStyle(color: Theme.of(context).colorScheme.tertiary, fontWeight: FontWeight.bold),),
                        Text('View other sacco members.',style: TextStyle(color: Theme.of(context).colorScheme.tertiary)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            RoundedButton(
                              color: colors.green,
                              onTap: ()=>membersBottomSheet(context),
                              text: 'View',
                              width: 100,
                              height: 36, borderRadius: BorderRadius.circular(18),)
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<dynamic> membersBottomSheet(BuildContext context){
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
              height: MediaQuery.of(context).size.height/1.05,
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  const SizedBox(height: 18,),
                  Container(
                    height: 60,
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: colors.green,
                        borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('Sacco Members',style: TextStyle(fontWeight: FontWeight.bold, color: colors.white)),
                  ),
                  const SizedBox(height: 12,),
                  Expanded(
                      child: FutureBuilder(
                        future: getAllMembers(),
                        builder: (context, snapshot){
                          if(snapshot.hasData){
                            membersList = snapshot.data;
                            return ListView.separated(
                              itemCount: membersList == null? 0: membersList!.length,
                              itemBuilder: (BuildContext context, int index){
                                Member? members = membersList?[index];
                                return SizedBox(
                                  height: 48,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Text('${members!.id}:', style: const TextStyle(fontWeight: FontWeight.bold),),
                                        const SizedBox(width: 2,),
                                        Text(members.midName != '' ?'${members.firstName} ${members.midName}' : '${members.firstName} ${members.lastName}', style: TextStyle(fontWeight: FontWeight.bold),),
                                        ],
                                    ),
                                  ),
                                );
                              }, separatorBuilder: (BuildContext context, int index) => MyDivider(),
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

  Future<dynamic> contributionsBottomSheet(BuildContext context){
    return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        isDismissible: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10)
          ),
        ),
        builder: (context){
          return SingleChildScrollView(
            child: SizedBox(
              height: MediaQuery.of(context).size.height/1.05,
              // padding: EdgeInsets.all(8),
              child: Column(
                children: [
                  const SizedBox(height: 12,),
                  Container(
                    height: 60,
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: colors.green,
                      borderRadius: BorderRadius.circular(4),
                      // border: Border.all(width: 1.0)
                    ),
                    child: Text('Contribution History', style: TextStyle(fontWeight: FontWeight.bold, color: colors.white),),
                  ),
                  const SizedBox(height: 8,),
                  Expanded(
                      child: FutureBuilder(
                        future: getMemberContributions(),
                        builder: (context, snapshot){
                          if(snapshot.hasData){
                            contributionList = snapshot.data;
                            return ListView.builder(
                              itemCount: contributionList == null? 0: contributionList!.length,
                              itemBuilder: (BuildContext context, int index){
                                Contribution? contributions = contributionList?[index];
                                return SizedBox(
                                  height: 100,
                                  child: Card(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Text('Date:', style: TextStyle(fontWeight: FontWeight.bold),),
                                              Text(DateFormat('dd MMM yyyy').format(DateTime.parse(contributions!.contributionDate!)).toString(), style: TextStyle(fontWeight: FontWeight.bold),),
                                            ],
                                          ),
                                          MyDivider(),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Text('Contribution Type:'),
                                              Text('${contributions.contributionType}')
                                            ],
                                          ),

                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Text('Amount:'),
                                              Text('Ksh ${contributions.amount}')
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          }
                          return const Text('Loading...');
                            // Center(
                            //   child: SizedBox(
                            //       width: 46,
                            //       height: 46,
                            //       child: CircularProgressIndicator(color: colors.green,)));
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

