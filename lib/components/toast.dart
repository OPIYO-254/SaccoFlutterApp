
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sojrel_sacco_client/utils/colors.dart';

class MyToast{
  MyColors colors = MyColors();
  showToast(String text){
    return Fluttertoast.showToast(
        msg: text,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: colors.white,
        textColor: colors.green,
        fontSize: 16.0
    );
  }
}