import 'package:conduit/conduit.dart';
import 'package:coschon/models/user.dart';
class UserController extends ResourceController {
  final ManagedContext context;
  UserController(this.context);
  @Operation.get()
  Future<Response> getUserUschus() async {
    final userQuery = Query<User>(context)
      ..where((i) => i.id).equalTo(request!.authorization!.ownerID);
    final user = await userQuery.fetchOne();
    return Response.ok({ "type": user!.uschus!.index });
  }
}