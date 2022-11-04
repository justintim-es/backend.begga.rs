import 'package:coschon/coschon.dart';

class Transfer extends Serializable {
  String? to;
  BigInt? gla;

  Map<String, dynamic> asMap() => {'to': to, 'gla': gla};
  void readFromMap(Map<String, dynamic> object) {
    to = object['to'].toString();
    gla = BigInt.parse(object['gla'].toString());
  }
}
