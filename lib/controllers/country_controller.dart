import 'package:conduit/conduit.dart';
import 'package:coschon/models/config.dart';
import 'package:coschon/models/country.dart';
import 'package:coschon/models/country_in.dart';
class CountryController extends ResourceController {
  ManagedContext context;
  Config config;
  CountryController(this.config, this.context);

  @Scope(['admin'])
  @Operation.post()
  Future<Response> add(@Bind.body() CountryIn country) async {
    final countryQuery = Query<Country>(context)
      ..values.code = country.code
      ..values.country = country.country;
    final inserted = await countryQuery.insert();
    return Response.ok("");
  }

}