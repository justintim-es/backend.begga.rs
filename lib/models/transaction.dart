import 'package:conduit/conduit.dart';
import 'package:coschon/models/ad_title.dart';
import 'user.dart';

class Transaction extends ManagedObject<_Transaction> implements _Transaction {}

class _Transaction {
  @primaryKey
  int? txId;

  String? blockchainIdentitatis;
  @Relate(#transactions)
  User? user;
}
