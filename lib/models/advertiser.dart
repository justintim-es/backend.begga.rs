import 'package:coschon/coschon.dart';

class Advertiser extends Serializable {
  String? email;
  String? username;
  String? password;
  Map<String, dynamic> asMap() =>
      {'email': email, 'username': username, 'password': password};
  void readFromMap(Map<String, dynamic> inputMap) {
    email = inputMap['email'].toString();
    username = inputMap['username'].toString();
    password = inputMap['password'].toString();
  }
}
