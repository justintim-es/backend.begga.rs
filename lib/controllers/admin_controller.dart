import 'package:conduit/conduit.dart';
import 'package:coschon/models/advertiser.dart';
import 'package:coschon/models/user.dart'; 
import 'package:random_string/random_string.dart';
import 'package:conduit/managed_auth.dart';
class AdminController extends ResourceController {
  ManagedContext context;
  AuthServer authServer;
  AdminController(this.context, this.authServer);
  
  @Operation.post()
  Future<Response> create(@Bind.body() Advertiser advertiser) async {
    final salt = generateRandomSalt();
    final userQuery = Query<User>(context)
      ..values.uschus = Uschus.admin
      ..values.username = advertiser.username 
      ..values.email = advertiser.email
      ..values.confirmEmail = randomAlphaNumeric(32)
      ..values.isConfirmedEmail = true
      ..values.public = 'public'
      ..values.salt = salt
      ..values.hashedPassword = authServer.hashPassword(advertiser.password!, salt)
      ..values.private  = 'private';
    final user = await userQuery.insert();
    return Response.ok("");
  }
}