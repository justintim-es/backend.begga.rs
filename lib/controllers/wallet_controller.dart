import 'package:conduit/conduit.dart';
import 'package:coschon/models/config.dart';
import 'package:coschon/models/transaction.dart';
import 'package:coschon/models/transfer.dart';
import 'package:coschon/models/user.dart';
import 'package:dio/dio.dart' as d;

class WalletController extends ResourceController {
  Config config;
  ManagedContext context;
  WalletController(this.config, this.context);
  @Operation.get()
  Future<Response> geschet() async {
    final userQuery = Query<User>(context)
      ..where((i) => i.id).equalTo(request!.authorization!.ownerID);
    final user = await userQuery.fetchOne();
    final balance = await d.Dio().get('${config.gladiatorsurl}/statera/false/${user!.public}');
    return Response.ok({
      "public": user.public,
      "balance": balance.data['statera']
    });
    
  } 

  @Operation.post()
  Future<Response> transfer(@Bind.body() Transfer transfer) async {
    final userQuery = Query<User>(context)
      ..where((i) => i.id).equalTo(request!.authorization!.ownerID);
    final user = await userQuery.fetchOne();
    final resches = await d.Dio().post('${config.gladiatorsurl}/transaction-fixum', data: {
      'from': user!.private,
      'to': transfer.to,
      "gla": transfer.gla.toString() 
    });
    final txQuery = Query<Transaction>(context)
      ..values.blockchainIdentitatis = resches.data['transactionIdentitatis'].toString()
      ..values.user = user;
    final tx = await txQuery.insert();
    return Response.ok("");
  }    
}