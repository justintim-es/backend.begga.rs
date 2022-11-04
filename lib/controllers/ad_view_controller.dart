import 'package:conduit/conduit.dart';
import 'package:coschon/coschon.dart';
import 'package:coschon/models/ad_title.dart';
import 'package:coschon/models/ad_view.dart';
import 'package:coschon/models/config.dart';
import 'package:dio/dio.dart' as d;
class AdViewController extends ResourceController {
  ManagedContext context;
  Config config;
  AdViewController(this.config, this.context) {
    policy!.allowedRequestHeaders = ['x-passenger', 'Authorization'];
  }
  //from here we can send a secondrequest to validate eather th baggerjwt or the passengerjwt
  @Operation.get('adId')
  Future<Response> first(@Bind.path('adId') int adId, @Bind.header('x-passenger') String passenger) async { 
    print('gotototo');
    print(passenger);
    final view = await d.Dio().post('${config.inner}/ad-payout/${request!.authorization!.ownerID}/$adId', data: null, options: d.Options(headers: {
      'Authorization': 'Bearer $passenger'
    }));
    return Response.ok(view.data);
  }
}