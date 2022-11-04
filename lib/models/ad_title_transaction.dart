import 'package:conduit/conduit.dart';
import 'package:coschon/models/ad_title.dart';

enum TransactionStatus { not, otw, arrived, forked, confirmed }

class AdTitleTransaction extends ManagedObject<_AdTitleTransaction>
    implements _AdTitleTransaction {}

class _AdTitleTransaction {
  @primaryKey
  int? id;

  TransactionStatus? status;

  String? identitatis;
  DateTime? date;
  @Relate(#adTitleTransactions)
  AdTitle? adTitle;
}
