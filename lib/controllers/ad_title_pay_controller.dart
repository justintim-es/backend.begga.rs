import 'package:conduit/conduit.dart';
import 'package:coschon/models/ad_title.dart';
import 'package:coschon/models/ad_title_transaction.dart';
import 'package:coschon/models/config.dart';
import 'package:coschon/models/transaction.dart';
import 'package:coschon/models/user.dart';
import 'package:dio/dio.dart' as d;
class AdTitlePayController extends ResourceController {
  ManagedContext context;
  Config config;
  AdTitlePayController(this.config, this.context);
  @Operation.get('adId')
  Future<Response> pay(@Bind.path('adId') int adId) async {
    final userQuery = Query<User>(context)
      ..where((i) => i.id).equalTo(request!.authorization!.ownerID);
    final user = await userQuery.fetchOne();
    final adQuery = Query<AdTitle>(context)
      ..where((i) => i.adTitleId).equalTo(adId);
    final ad = await adQuery.fetchOne();
    final gla = (BigInt.parse(ad!.ads.toString()) * BigInt.parse(ad.gla.toString())).toString();
    try {
      if(ad.fee! > 0) {
        final fee = await d.Dio().post('${config.gladiatorsurl}/transaction-fixum', data: {
          "from": user!.private,
          "to": config.me,
          "gla": ad.fee.toString()
        });
        final feeQuery  = Query<Transaction>(context)
          ..values.blockchainIdentitatis = fee.data['transactionIdentitatis'].toString()
          ..values.user = user;
        await feeQuery.insert();
      }
      final resches = await d.Dio().post('${config.gladiatorsurl}/transaction-fixum', data: {
        "from": user!.private,
        "to": ad.public,
        "gla": gla
      });
      final txQuery = Query<AdTitleTransaction>(context)
        ..values.identitatis = resches.data['transactionIdentitatis'].toString()
        ..values.status = TransactionStatus.otw
        ..values.date = DateTime.now()
        ..values.adTitle = ad;
      final tx = await txQuery.insert();
      return Response.ok("");
    } on d.DioError catch (err) {
      return Response.badRequest(body: err.response?.data);
    }
  }
  @Operation.get()
  Future<Response> all() async {
    final adTitlesQuery = Query<AdTitle>(context) 
    ..join(set: (ad) => ad.adTitleTransactions);
    final List<AdTitle> ads = await adTitlesQuery.fetch();
    for (int i = 0; i < ads.length; i++) {
      final statera = await d.Dio().get('${config.gladiatorsurl}/statera/false/${ads[i].public}');
      ads[i].balance = statera.data['statera'].toString();
        for (int ii = 0; ii < ads[i].adTitleTransactions!.length; ii++) {
          if (BigInt.parse(ads[i].balance!) > BigInt.zero) {
            if (ads[i].adTitleTransactions![ii].status != TransactionStatus.confirmed) {
              final tx = await d.Dio().get('${config.gladiatorsurl}/transaction/${ads[i].adTitleTransactions![ii].identitatis}');
              if (int.parse(tx.data['data']['confirmationes'].toString()) > config.confirmations!) {
                final updateTxQuery = Query<AdTitleTransaction>(context)
                    ..values.status = TransactionStatus.confirmed
                    ..where((i) => i.id).equalTo(ads[i].adTitleTransactions![ii].id);
                await updateTxQuery.updateOne();
              } else {
                final updateTxQuery = Query<AdTitleTransaction>(context)
                    ..values.status = TransactionStatus.arrived
                    ..where((i) => i.id).equalTo(ads[i].adTitleTransactions![ii].id);
                await updateTxQuery.updateOne();
              }
            } 
          } else {
            try {
              final tx = await d.Dio().get('${config.gladiatorsurl}/transaction/${ads[i].adTitleTransactions![ii].identitatis}');
            } on d.DioError catch (err) {
              final updateTxQuery = Query<AdTitleTransaction>(context)
                ..values.status = TransactionStatus.forked
                ..where((i) => i.id).equalTo(ads[i].adTitleTransactions!.first.id);
              await updateTxQuery.updateOne();
            }
          }
        }
    }
    final finishedQuery = Query<AdTitle>(context) 
    ..returningProperties((x) => [x.title, x.subtitle, x.ads, x.balance]);
    finishedQuery.join(set: (ad) => ad.adTitleTransactions).returningProperties((x) => [x.date, x.identitatis, x.status]);
    finishedQuery.join(set: (ad) => ad.adViews).returningProperties((x) => []);
    final List<AdTitle> aschads = await finishedQuery.fetch();
    return Response.ok(aschads);  
  }
}