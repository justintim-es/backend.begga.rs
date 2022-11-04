import 'package:conduit/conduit.dart';
import 'package:coschon/models/country.dart';

class CountriesController extends ResourceController {
  ManagedContext context;
  CountriesController(this.context);
  @Operation.get()
  Future<Response> countries() async {
    final countriesQuery = Query<Country>(context);
    final couns = await countriesQuery.fetch();
    return Response.ok(couns);
  }
}