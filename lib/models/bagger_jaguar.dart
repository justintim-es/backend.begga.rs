import 'package:coschon/coschon.dart';

class BaggerJaguar extends Serializable {
  String? bagger;

  Map<String, dynamic> asMap() => {'bagger': bagger};
  @override
  void readFromMap(Map<String, dynamic> object) {
    bagger = object['bagger'].toString();
  }
}
