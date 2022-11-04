import 'package:conduit/conduit.dart';
import 'package:coschon/models/ad_title.dart';
import 'package:coschon/models/user.dart';

class Country extends ManagedObject<_Country> implements _Country {}

class _Country {
  @primaryKey
  int? countryId;
  @Column(unique: true)
  String? country;
  @Column(unique: true)
  String? code;

  ManagedSet<User>? users;

  ManagedSet<AdTitle>? adTitles;
}
