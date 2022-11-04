import 'package:coschon/coschon.dart';
import 'package:conduit/conduit.dart';

class Ad extends ManagedObject<_Ad> implements _Ad {}

class _Ad {
  @primaryKey
  int? id;
  String? contents;
}
