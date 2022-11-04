import 'package:conduit/conduit.dart';

class ConfirmPhonenumber extends Serializable {
  String? token;
  int? confirmation;
  String? country;
  Map<String, dynamic> asMap() =>
      {'token': token, 'confirmation': confirmation, 'country': country};
  void readFromMap(Map<String, dynamic> inputMap) {
    token = inputMap['token'].toString();
    confirmation = int.parse(inputMap['confirmation'].toString());
    country = inputMap['country'].toString();
  }
}
