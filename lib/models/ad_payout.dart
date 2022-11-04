import 'package:conduit/conduit.dart';
import 'package:coschon/models/ad_title.dart';
import 'package:coschon/models/user.dart';

class AdPayout extends ManagedObject<_AdPayOut> implements _AdPayOut {}

class _AdPayOut {
  @primaryKey
  int? dbId;

  String? adPayoutId;

  DateTime? date;

  @Relate(#adPayouts)
  User? user;

  @Relate(#adPayouts)
  AdTitle? adTitle;
}
