import 'package:conduit/conduit.dart';
import 'package:coschon/models/ad_payout.dart';
import 'package:coschon/models/ad_view.dart';
import 'package:coschon/models/country.dart';
import 'package:coschon/models/user.dart';
import 'ad_title_transaction.dart';

class AdTitle extends ManagedObject<_AdTitle> implements _AdTitle {}

class _AdTitle {
  @primaryKey
  int? adTitleId;

  String? title;
  @Column(nullable: true)
  String? subtitle;
  @Column(nullable: true)
  String? link;
  String? gla;
  int? ads;

  @Relate(#adTitles)
  User? user;
  @Column(nullable: true)
  String? private;
  @Column(nullable: true)
  String? public;

  String? price;

  DateTime? date;
  @Column(nullable: true)
  String? balance;
  @Column(nullable: true)
  int? fee;

  ManagedSet<AdTitleTransaction>? adTitleTransactions;

  ManagedSet<AdView>? adViews;

  ManagedSet<AdPayout>? adPayouts;
  @Relate(#adTitles)
  Country? country;
}
