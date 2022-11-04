import 'package:conduit/conduit.dart';
import 'package:coschon/models/config.dart';
import 'package:coschon/models/transaction.dart';
import 'package:coschon/models/user.dart';
import 'package:dio/dio.dart' as d;
class TransactionsController extends ResourceController {
  ManagedContext context;
  Config config;
  TransactionsController(this.config, this.context);
  @Operation.get()
  Future<Response> transactions() async {
    final userQuery = Query<User>(context)
      ..where((i) => i.id).equalTo(request!.authorization!.ownerID);
    final user = await userQuery.fetchOne();
    final txQuey = Query<Transaction>(context)
      ..where((i) => i.user!.id).equalTo(request!.authorization!.ownerID);
    final txs = await txQuey.fetch();
    List<dynamic> reschets = [];
    for (Transaction tx in txs) {
      try {
        final resches = await d.Dio().get('${config.gladiatorsurl}/transaction/${tx.blockchainIdentitatis}');
        reschets.add({ "id": tx.blockchainIdentitatis, "extra": resches.data, "forked": false });
      } catch (err) {
        reschets.add({ "id": tx.blockchainIdentitatis, "extra": null, "forked": true });
      }
    }
    return Response.ok(reschets);
  }
  @Operation.get('id')
  Future<Response> transaction(@Bind.path('id') int id) async {
    final txQuery = Query<Transaction>(context)
      ..where((i) => i.txId).equalTo(id);
    final tx = await txQuery.fetchOne();
    return Response.ok("");
  }
} 