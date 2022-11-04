import 'dart:math';

import 'package:conduit/conduit.dart';
import 'package:coschon/models/ad_title.dart';
import 'package:coschon/models/ad_title_in.dart';
import 'package:coschon/models/config.dart';
import 'package:coschon/models/country.dart';
import 'package:coschon/models/ad_title_transaction.dart';
import 'package:dio/dio.dart' as d;
import '../models/user.dart';


class AdvertiserTitleController extends ResourceController {
    Config config;
    ManagedContext context;
    AdvertiserTitleController(this.config, this.context);

    @Operation.post()
    Future<Response> create(@Bind.body() AdTitleIn adTitleIn) async {
      final userQuery = Query<User>(context)
        ..where((x) => x.id).equalTo(request!.authorization!.ownerID);
      final user = await userQuery.fetchOne();
      final resches = await d.Dio().get('${config.gladiatorsurl}/rationem');
      final countryQuery = Query<Country>(context)..where((i) => i.country).equalTo(adTitleIn.country);
      final country = await countryQuery.fetchOne();
      final insertAdQuery = Query<AdTitle>(context)
        ..values.title = adTitleIn.title
        ..values.subtitle = adTitleIn.subtitle
        ..values.link = adTitleIn.link
        ..values.gla = adTitleIn.gla.toString()
        ..values.ads = adTitleIn.ads
        ..values.public = resches.data['publicaClavis'].toString()
        ..values.private = resches.data['privatusClavis'].toString()
        ..values.price = (BigInt.parse(adTitleIn.gla.toString()) * BigInt.parse(adTitleIn.ads.toString())).toString()
        ..values.date = DateTime.now()
        ..values.country = country
        ..values.user = user;
      final ad = await insertAdQuery.insert();
      return Response.ok({ "id": ad.adTitleId });
    } 
    @Operation.get('id')
    Future<Response> preview(@Bind.path('id') int id) async {
      final adQuery = Query<AdTitle>(context)
        ..where((i) => i.adTitleId).equalTo(id);
      final ad = await adQuery.fetchOne();
      final resches = await d.Dio().get('https://backend.gladiato.rs/api/sell/average');
      
      if(resches.data['averageFixum'] == 0) {
        final adUpdateQuery = Query<AdTitle>(context)
          ..values.fee = 0
          ..where((i) => i.adTitleId).equalTo(id);
        final updated = await adUpdateQuery.updateOne();
        return Response.ok({
          "title": ad!.title,
          "subtitle": ad.subtitle,
          "link": ad.link,
          "gla": (BigInt.parse(ad.ads.toString()) * BigInt.parse(ad.gla.toString())).toString(),
          "fee": 0
        });
      } else {
        final serviceFee = (1 / int.parse(resches.data['averageFixum'].toString()) * ad!.ads!).floor();
        final adUpdateQuery = Query<AdTitle>(context)
          ..values.fee = serviceFee
          ..where((i) => i.adTitleId).equalTo(id);
        final updated = await adUpdateQuery.updateOne();
        return Response.ok({
          "title": ad.title,
          "subtitle": ad.subtitle,
          "link": ad.link,
          "gla": (BigInt.parse(ad.ads.toString()) * BigInt.parse(ad.gla.toString())).toString(),
          "fee": serviceFee
        });
      }
    }
    @Operation.get()
    Future<Response> expensive() async {
      final baggerQuery = Query<User>(context)..where((u) => u.id).equalTo(request!.authorization!.ownerID);
      final bagger = await baggerQuery.fetchOne();
      final adQuery = Query<AdTitle>(context)..where((ad) => ad.country!.countryId).equalTo(bagger!.country!.countryId)..join(set: (ad) => ad.adTitleTransactions);
      final ads = await adQuery.fetch();
      if(ads.where((x) => x.adTitleTransactions!.every((y) => y.status == TransactionStatus.confirmed)).isEmpty) {
        return Response.ok({ "id": 0 });
      }
      final ex = ads.reduce((a, b) {
        if(BigInt.parse(a.gla!) > BigInt.parse(b.gla!)) {
          return a;
        } else {
          return b;
        }
      });
      return Response.ok({ "id": ex.adTitleId });
    }
}