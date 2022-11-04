import 'package:conduit/conduit.dart';
import 'package:coschon/models/user.dart';
import '../models/ad_payout.dart';
import '../models/config.dart';
import 'package:dio/dio.dart' as d;
class AdPayoutsController extends ResourceController {
  ManagedContext context;
  Config config;
  AdPayoutsController(this.context, this.config);
  
  @Operation.get()
  Future<Response> getPayouts() async {
    final payoutsQuery = Query<AdPayout>(context)
      ..where((i)  => i.user!.id).equalTo(request!.authorization!.ownerID);
    final payouts = await payoutsQuery.fetch(); 
    final baggerQuery = Query<User>(context)..where((x) => x.id).equalTo(request!.authorization!.ownerID);
    final bagger = await baggerQuery.fetchOne();
    for (int i = 0; i < payouts.length; i++) {
      try {
        final tx = await d.Dio().get('${config.gladiatorsurl}/transaction/${payouts[i].adPayoutId}');
      } on d.DioError catch (e) {
        final fixum = await d.Dio().post('${config.gladiatorsurl}/transaction-fixum', data: {
          'from': payouts[i].adTitle!.private,
          'to': bagger!.public,
          'gla': payouts[i].adTitle!.gla
        });
      }
    }
    return Response.ok(payouts);

  }
}