import 'package:conduit/conduit.dart';
import 'package:coschon/models/config.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';
class JaguarController extends ResourceController {
    Config config;
    JaguarController(this.config);
    @Operation.get()
    Future<Response> encrypt() async {
      final claimset = JwtClaim(
        otherClaims: {
          'bagger': request!.authorization!.ownerID
        }
      );
      String token = issueJwtHS256(claimset, config.jaguar!);
      return Response.ok(token);        
    }
}