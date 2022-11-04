import 'package:conduit/conduit.dart';
import 'package:coschon/models/ad_title.dart';
import 'package:coschon/models/user.dart';

class AdView extends ManagedObject<_AdView> implements _AdView {}

class _AdView {
  @primaryKey
  int? adViewId;

  @Relate(#adViews)
  User? passenger;

  @Relate(#adViews)
  AdTitle? adTitle;
  @Relate(#adEarns)
  User? bagger;
}
