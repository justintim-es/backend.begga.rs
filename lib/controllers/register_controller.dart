import 'package:conduit/conduit.dart';
import 'package:coschon/models/config.dart';
import 'package:coschon/models/country.dart';
import 'package:coschon/models/user.dart';
import 'package:random_string/random_string.dart';
import 'package:coschon/models/advertiser.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:dio/dio.dart' as d;

class RegisterController extends ResourceController {
    final ManagedContext context;
    final AuthServer authServer;
    final SmtpServer smtp;
    final Config config;
    RegisterController(this.context, this.authServer, this.smtp, this.config); 

    @Operation.post('bagger')
    Future<Response> register(@Bind.path('bagger') String bagger, @Bind.body() Advertiser advertiser) async { 
      if (advertiser.username == null || advertiser.password == null || advertiser.username == null) {
        return Response.badRequest(
          body: "email, username and password are required"
        );
      }
      final rationem = await d.Dio().get('${config.gladiatorsurl}/rationem');

      final salt = generateRandomSalt();
      final confirm = randomAlphaNumeric(256);
      final insertQuery = Query<User>(context)
        ..values.uschus = bagger == 'true' ? Uschus.bagger : Uschus.advertiser
        ..values.email = advertiser.email
        ..values.username = advertiser.username
        ..values.confirmEmail = confirm
        ..values.isConfirmedEmail = false
        ..values.phonenumber          
        ..values.salt = salt
        ..values.private = rationem.data['privatusClavis'].toString()
        ..values.public = rationem.data['publicaClavis'].toString()
        ..values.hashedPassword = authServer.hashPassword(advertiser.password!, salt);
      final msg = Message()
        ..from = Address(config.smtp!.username!, 'Bagge.rs')
        ..recipients.add(advertiser.email)
        ..subject = 'Please confirm your e-mail'    
        ..text = 'Please confirm your e-mail by pressing on the following link\n${config.frontend}/confirm-fetch/${bagger == 'true' ? 'true' : 'false'}/$confirm';
      await send(msg, smtp);
      await insertQuery.insert();
      return Response.ok("");
      
    }
    @Operation.post('bagger', 'adId')
    Future<Response> passenger(@Bind.path('bagger') String bagger, @Bind.path('adId') int adId, @Bind.body() Advertiser advertiser) async { 
      if (advertiser.username == null || advertiser.password == null || advertiser.username == null) {
        return Response.badRequest(
          body: "email, username and password are required"
        );
      }
      final rationem = await d.Dio().get('${config.gladiatorsurl}/rationem');
      final salt = generateRandomSalt();
      final confirm = randomAlphaNumeric(256);
      final insertQuery = Query<User>(context)
        ..values.uschus = Uschus.passenger
        ..values.email = advertiser.email
        ..values.username = advertiser.username
        ..values.confirmEmail = confirm
        ..values.isConfirmedEmail = false
        ..values.salt = salt
        ..values.private = rationem.data['privatusClavis'].toString()
        ..values.public = rationem.data['publicaClavis'].toString()
        ..values.hashedPassword = authServer.hashPassword(advertiser.password!, salt);
      final msg = Message()
        ..from = Address(config.smtp!.username!, 'Bagge.rs')
        ..recipients.add(advertiser.email)
        ..subject = 'Please confirm your e-mail'    
        ..text = 'Please confirm your e-mail by pressing on the following link\n${config.frontend}/confirm-fetch-passenger/$adId/$bagger/$confirm';
      await send(msg, smtp);
      await insertQuery.insert();
      return Response.ok("");
  }
}   