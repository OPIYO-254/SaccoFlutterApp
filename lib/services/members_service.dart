import 'dart:convert';
import 'dart:io';

import '../controller/members_controller.dart';
import '../models/member_model.dart';
import '../utils/shared_preferences.dart';

class MemberService {

  // Future<Map<String, dynamic>> fetchMemberData() async {
  //   MySharedPreferences mySharedPreferences = MySharedPreferences();
  //   final String? storedData = await mySharedPreferences.getDataIfNotExpired("membersList");
  //   late Map<String, dynamic> jsonData;
  //   try {
  //     final result = await InternetAddress.lookup('www.sojrelsacco.com');
  //     // print(result[0]);
  //     if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {//check if device is connected
  //       // print('connected');
  //       if (storedData != null) {//check if there is data in cache else fetch it from server and assign it to jsonData
  //         jsonData = jsonDecode(storedData);
  //       }
  //       else{
  //         Response res = await MemberApi().getMember();
  //         jsonData = await jsonDecode(res.body.trim());
  //         if (res.statusCode == 200) {
  //           await mySharedPreferences.saveDataWithExpiration('membersList',
  //               res.body, const Duration(minutes: 10));
  //         }
  //       }
  //     }
  //     else{
  //       // print('not connected');
  //       if (storedData != null) {//check if there is data in cache else fetch it from server and assign it to jsonData
  //         jsonData = jsonDecode(storedData);
  //       }
  //       else{
  //         throw Exception("Not found");
  //       }
  //       throw Exception("not found");
  //     }
  //     return jsonData;
  //   } on SocketException catch (_) {
  //     // print('error! not connected');
  //     if (storedData != null) {//check if there is data in cache else fetch it from server and assign it to jsonData
  //       jsonData = jsonDecode(storedData);
  //     }
  //   }
  //   return jsonData;
  //
  // }


  Future<List<Member>?> fetchMembers() async {
    var res = await MembersApi().getAllMembers();
    List jsonData = jsonDecode(res.body);
    List<Member> members=[];
    if(jsonData != []){
      for (var e in jsonData) {
        Member member = Member();
        member.id=e['id'];
        member.firstName=e['firstName'];
        member.midName=e['midName'];
        member.lastName=e['lastName'];
        member.residence=e['residence'];
        members.add(member);
      }
    }
    return members;

  }


}