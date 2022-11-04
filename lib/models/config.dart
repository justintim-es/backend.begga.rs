import 'package:conduit/conduit.dart';
import 'package:coschon/coschon.dart';

class Config extends Configuration {
  Config(String fileName) : super.fromFile(File(fileName));
  String? gladiatorsurl;
  int? confirmations;
  String? inner;
  String? averageBackend;
  String? smsApiKey;
  String? frontend;
  String? jaguar;
  String? me;
  Database? database;
  Smtp? smtp;
}

class Database extends Configuration {
  String? username;
  String? password;
  String? host;
  int? port;
  String? name;
}

class Smtp extends Configuration {
  String? username;
  String? password;
}
