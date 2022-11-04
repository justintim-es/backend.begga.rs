import 'package:conduit/conduit.dart';
import 'package:coschon/models/ad_payout.dart';
import 'package:coschon/models/ad_title.dart';
import 'package:coschon/models/ad_view.dart';
import 'package:coschon/models/bagger_jaguar.dart';
import 'package:coschon/models/config.dart';
import 'package:coschon/models/config.dart';
import 'package:coschon/models/user.dart';
import 'package:dio/dio.dart' as d;
import 'package:jaguar_jwt/jaguar_jwt.dart';
//optional tip for the bagger later
//so it has to be cors protected that only our website can call it
//en still we would lie to have bagger as integer because then you can reward another bagger without corsofcourse
class AdPayoutController extends ResourceController {
    ManagedContext context;
    Config config;
    AdPayoutController(this.config, this.context) {
      // policy!.allowedOrigisns = ['http://localhost:8888'];
    }
    
    @Operation.post('adId')
    Future<Response> transferAd(@Bind.path('adId') int adId, @Bind.body() BaggerJaguar baggerJaguar) async {
      final adTitleQuery = Query<AdTitle>(context)..where((i) => i.adTitleId).equalTo(adId);
      final adTitle = await adTitleQuery.fetchOne();
        final adViewsQuery = Query<AdView>(context)
        ..where((i) => i.adTitle!.adTitleId).equalTo(adId);
      final adViews = await adViewsQuery.fetch();
      final JwtClaim claim = verifyJwtHS256Signature(baggerJaguar.bagger!, config.jaguar!);
      print(claim);
      if (
        adViews.length < adTitle!.ads! &&       
        adViews.where((element) => element.bagger!.id == claim['bagger'] && element.passenger!.id == request!.authorization!.ownerID).isEmpty) {
        final adViewQuery = Query<AdView>(context)
          ..values.adTitle!.adTitleId = adId    
          ..values.bagger!.id = int.parse(claim['bagger'].toString())
          ..values.passenger!.id = request!.authorization!.ownerID;
        await adViewQuery.insert();
        final baggerQuery = Query<User>(context)..where((i) => i.id).equalTo(int.parse(claim['bagger'].toString()));
        final baschag = await baggerQuery.fetchOne();
        try {
          final tx = await d.Dio().post('${config.gladiatorsurl}/transaction-fixum', data: {
            "from": adTitle.private,
              "to":  baschag!.public,
              "gla": adTitle.gla!
          });
          final payoutQuery = Query<AdPayout>(context)
            ..values.adPayoutId = tx.data['transactionIdentitatis'].toString()
            ..values.adTitle = adTitle
            ..values.date = DateTime.now()
            ..values.user = baschag;
          final payout = await payoutQuery.insert();
        } on d.DioError catch (err) {
          return Response.badRequest(body: err.response!.data);
        }
          
      } else {
        return Response.badRequest(body: { "title": 'Sold out', "subtitle": 'would you like to advertise here?', 'link': 'bagge.rs' });
      }     
      return Response.ok({
        "title": adTitle.title,
        "subtitle": adTitle.subtitle,
        "link": adTitle.link
      });
    } 
}