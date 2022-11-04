import 'package:conduit/conduit.dart';
import 'package:coschon/models/user.dart';

class ConfirmEmailController extends ResourceController {
    ManagedContext context;
    ConfirmEmailController(this.context);
    
    @Operation.post('token')
    Future<Response> confirm(@Bind.path('token') String token) async {
      final userQuery = Query<User>(context)
        ..values.isConfirmedEmail = true
        ..where((x) => x.confirmEmail).equalTo(token);
      await userQuery.updateOne();
      return Response.ok("");
    }
}