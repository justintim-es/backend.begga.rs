import 'package:coschon/coschon.dart';

class CountryIn extends Serializable {
  String? code;
  String? country;

  @override
  Map<String, dynamic> asMap() => {'code': code, 'country': country};

  @override
  void readFromMap(Map<String, dynamic> object) {
    code = object['code'].toString();
    country = object['country'].toString();
  }
}
