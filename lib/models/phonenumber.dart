import 'package:coschon/coschon.dart';

class Phonenumber extends Serializable {
  String? token;
  String? language;
  String? phonenumber;
  Map<String, dynamic> asMap() =>
      {'token': token, 'language': language, 'phonenumber': phonenumber};
  void readFromMap(Map<String, dynamic> inputMap) {
    token = inputMap['token'].toString();
    language = inputMap['language'].toString();
    phonenumber = inputMap['phonenumber'].toString();
  }
}
