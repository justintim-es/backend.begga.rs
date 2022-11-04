import 'package:conduit/conduit.dart';
import 'package:conduit/managed_auth.dart';
import 'package:coschon/models/ad_payout.dart';
import 'package:coschon/models/ad_title.dart';
import 'package:coschon/models/ad_view.dart';
import 'package:coschon/models/country.dart';
import 'package:coschon/models/transaction.dart';

enum Uschus { advertiser, bagger, passenger, admin }

class User extends ManagedObject<_User>
    implements _User, ManagedAuthResourceOwner<_User> {}

class _User extends ResourceOwnerTableDefinition {
  Uschus? uschus;
  @Column(unique: true)
  String? email;
  @Column(nullable: true, unique: true)
  String? phonenumber;
  @Column(unique: true)
  String? confirmEmail;
  bool? isConfirmedEmail;
  @Column(nullable: true)
  int? confirmPhonenumber;
  @Column(nullable: true)
  bool? isConfirmedPhonenumber;

  String? public;
  String? private;

  ManagedSet<AdTitle>? adTitles;

  ManagedSet<Transaction>? transactions;

  ManagedSet<AdView>? adViews;

  ManagedSet<AdView>? adEarns;

  ManagedSet<AdPayout>? adPayouts;

  @Relate(#users)
  Country? country;
}
