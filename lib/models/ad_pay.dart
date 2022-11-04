import 'package:conduit/conduit.dart';
import 'package:coschon/models/ad_title.dart';

class AdPay extends ManagedObject<_AdPay> implements _AdPay {}

class _AdPay {
  @primaryKey
  int? id;

  String? private;

  String? public;

  AdTitle? adTitle;
}
