import 'dart:convert';

import '../controller/members_controller.dart';
import '../models/member_model.dart';

class MemberService {
  Future<List<Member>?> fetchMembers() async {
    var res = await MembersApi().getAllMembers();
    List jsonData = jsonDecode(res.body);
    List<Member> members=[];
    if(jsonData != []){
      jsonData.forEach((e) {
        Member member = Member();
        member.id=e['id'];
        member.firstName=e['firstName'];
        member.midName=e['midName'];
        member.lastName=e['lastName'];
        member.residence=e['residence'];
        members.add(member);
      });
    }
    return members;

  }


}