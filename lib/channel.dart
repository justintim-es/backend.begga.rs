import 'package:conduit/managed_auth.dart';
import 'package:coschon/controllers/ad_payout_controller.dart';
import 'package:coschon/controllers/ad_payouts_controller.dart';
import 'package:coschon/controllers/ad_title_pay_controller.dart';
import 'package:coschon/controllers/ad_view_controller.dart';
import 'package:coschon/controllers/admin_controller.dart';
import 'package:coschon/controllers/confirm_email_controller.dart';
import 'package:coschon/controllers/confirm_phonenumber_controller.dart';
import 'package:coschon/controllers/countries_controller.dart';
import 'package:coschon/controllers/country_controller.dart';
import 'package:coschon/controllers/jaguar_controller.dart';
import 'package:coschon/controllers/phonenumber_controller.dart';
import 'package:coschon/controllers/register_controller.dart';
import 'package:coschon/controllers/transactions_controller.dart';
import 'package:coschon/controllers/upload_controller.dart';
import 'package:coschon/controllers/user_controller.dart';
import 'package:coschon/controllers/wallet_controller.dart';
import 'package:coschon/coschon.dart';
import 'package:coschon/models/ad.dart';
import 'package:coschon/models/config.dart';
import 'package:coschon/models/user.dart';
import 'package:mailer/smtp_server.dart';
import 'package:coschon/models/recog.dart';
import 'package:coschon/models/ad_title.dart';
import 'package:coschon/controllers/advertiser_title_controller.dart';
import 'package:coschon/models/ad_title_transaction.dart';
import 'package:coschon/models/ad_view.dart';
import 'package:coschon/models/ad_payout.dart';
import 'package:coschon/models/country.dart';

/// This type initializes an application.
///
/// Override methods in this class to set up routes and initialize services like
/// database connections. See http://conduit.io/docs/http/channel/.
class CoschonChannel extends ApplicationChannel {
  /// Initialize services in this method.
  ///
  /// Implement this method to initialize services, read values from [options]
  /// and any other initialization required before constructing [entryPoint].
  ///
  /// This method is invoked prior to [entryPoint] being accessed.
  ManagedContext? coschon;
  AuthServer? authServer;
  SmtpServer? smtp;
  Config? config;
  @override
  Future prepare() async {
    logger.onRecord.listen(
        (rec) => print("$rec ${rec.error ?? ""} ${rec.stackTrace ?? ""}"));
    var dataModel = ManagedDataModel.fromCurrentMirrorSystem();
    config = Config(options!.configurationFilePath!);
    var psc = PostgreSQLPersistentStore.fromConnectionInfo(config!.database!.username, config!.database!.password, config!.database!.host, config!.database!.port, config!.database!.name);
    coschon = ManagedContext(dataModel, psc); 
    final delegate = RoleBasedAuthDelegate(coschon!);
    authServer = AuthServer(delegate);  
    smtp = gmail(config!.smtp!.username!, config!.smtp!.password!);
  }

  /// Construct the request channecode l.
  ///
  /// Return an instance of some [Controller] that will be the initial receiver
  /// of all [Request]s.
  ///
  /// This method is invoked after [prepare]. 
  @override
  Controller get entryPoint {
    final router = Router();

    // Prefer to use `link` instead of `linkFunction`.
    // See: https://conduit.io/docs/http/request_controller/
    router.route("/example").linkFunction((request) async {
      return Response.ok({"key": "value"});
    });
    router.route('/register/:bagger/[:adId]').link(() => RegisterController(coschon!, authServer!, smtp!, config!));
    router.route('/confirm-email/:token').link(() =>  ConfirmEmailController(coschon!));
    router.route('/phonenumber').link(() => PhonenumberController(config!, coschon!));
    router.route('/confirm-phonenumber').link(() => ConfirmPhonenumberController(coschon!));
    router.route('/upload').link(() => UploadController(coschon!));
    router.route('/auth/token').link(() => AuthController(authServer!));

    router.route('/user')
    .link(() => Authorizer.bearer(authServer!))
    !.link(() => UserController(coschon!));
    router.route('/advertiser-title/[:id]')
    .link(() => Authorizer.bearer(authServer!))
    !.link(() => AdvertiserTitleController(config!, coschon!));
    router.route('/ad-title-pay/[:adId]')
    .link(() => Authorizer.bearer(authServer!, scopes: ['advertiser']))
    !.link(() => AdTitlePayController(config!, coschon!));
    router.route('/wallet')
    .link(() => Authorizer.bearer(authServer!))
    !.link(() => WalletController(config!, coschon!));

    router.route('/admin')
    .link(() => AdminController(coschon!, authServer!));
    router.route('/transactions/[:id]')
    .link(() => Authorizer.bearer(authServer!))
    !.link(() => TransactionsController(config!, coschon!));
    router.route('/ad-view/:adId')
    .link(() => Authorizer.bearer(authServer!, scopes: ['passenger']))
    !.link(() => AdViewController(config!, coschon!));
    router.route('/ad-payout/:adId')
    .link(() => Authorizer.bearer(authServer!, scopes: ['passenger']))
    !.link(() => AdPayoutController(config!, coschon!));

    router.route('/jaguar')
    .link(() => Authorizer.bearer(authServer!, scopes: ['bagger']))
    !.link(() => JaguarController(config!));    

    router.route('/ad-payouts')
    .link(() => Authorizer.bearer(authServer!, scopes: ['bagger']))
    !.link(() => AdPayoutsController(coschon!, config!));

    router.route('/country')
    .link(() => Authorizer.bearer(authServer!))
    !.link(() => CountryController(config!, coschon!));

    router.route('/countries').link(() => CountriesController(coschon!));
    return router;
  } 
}
class RoleBasedAuthDelegate extends ManagedAuthDelegate<User> {
  RoleBasedAuthDelegate(ManagedContext context, {int tokenLimit: 40}) :
        super(context, tokenLimit: tokenLimit);

  @override
  Future<User?> getResourceOwner(
      AuthServer server, String username) {
    final query = Query<User>(context!)
      ..where((u) => u.username).equalTo(username)
      ..returningProperties((t) =>
        [t.id, t.username, t.hashedPassword, t.salt, t.uschus]);

    return query.fetchOne();
  }

  @override
  List<AuthScope> getAllowedScopes(covariant User user) {
    List<String> scopeStrings = [];
    if (user.uschus == Uschus.advertiser) {
      scopeStrings = ["advertiser"];
    } else if (user.uschus == Uschus.bagger) {
      scopeStrings = ["bagger"];
    } else if (user.uschus == Uschus.passenger) {
      scopeStrings = ["passenger"];
    } else if (user.uschus == Uschus.admin) {
      scopeStrings = ["admin"];
    }
    return scopeStrings.map((str) => AuthScope(str)).toList();
  }
}