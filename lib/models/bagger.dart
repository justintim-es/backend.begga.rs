import 'package:conduit/conduit.dart';

class Bagger extends Serializable {
  String? email;
  String? username;
  String? phonenumber;
  String? password;
  Map<String, dynamic> asMap() =>
      {'email': email, 'phonenumber': phonenumber, 'password': password};
  void readFromMap(Map<String, dynamic> inputMap) {
    email = inputMap['email'].toString();
    username = inputMap['username'].toString();
    phonenumber = inputMap['phonenumber'].toString();
    password = inputMap['password'].toString();
  }
}
