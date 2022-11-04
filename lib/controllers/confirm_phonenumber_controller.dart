import 'package:conduit/conduit.dart';
import 'package:coschon/models/confirm_phonenumber.dart';
import 'package:coschon/models/user.dart';

import '../models/country.dart';

class ConfirmPhonenumberController extends ResourceController {
  ManagedContext context;
  ConfirmPhonenumberController(this.context);

  @Operation.post()
  Future<Response> confirmPhonenumber(@Bind.body() ConfirmPhonenumber confirmPhonenumber) async {
    print(confirmPhonenumber.asMap());
    final userQuery = Query<User>(context)..where((i) =>  i.confirmEmail).equalTo(confirmPhonenumber.token);
    final user = await userQuery.fetchOne();
    print(user!.confirmPhonenumber);
    print(confirmPhonenumber.confirmation);
    final countryQuery = Query<Country>(context)..where((c) => c.country).equalTo(confirmPhonenumber.country);
    final country = await countryQuery.fetchOne();
    if (user.confirmPhonenumber != confirmPhonenumber.confirmation) {
      return Response.badRequest(body: "Invalid confirmation token");
    } 
    final updateUserQuery = Query<User>(context)
      ..values.isConfirmedPhonenumber = true
      ..values.country = country
      ..where((i) => i.confirmEmail).equalTo(confirmPhonenumber.token);
    await updateUserQuery.updateOne();
    return Response.ok("");
  }
}