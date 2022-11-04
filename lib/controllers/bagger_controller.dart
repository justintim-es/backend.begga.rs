import 'package:conduit/conduit.dart';
import 'package:coschon/models/ad_title.dart';  

class BaggerController extends ResourceController {
  ManagedContext context;
  BaggerController(this.context);
  
  @Operation.get()
  Future<Response> expensive() async {
    final adQuery = Query<AdTitle>(context);
    final ads = await adQuery.fetch();
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