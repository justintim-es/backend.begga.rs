import 'package:conduit/conduit.dart';
import 'package:coschon/models/config.dart';
import 'package:coschon/models/phonenumber.dart';
import 'package:coschon/models/recog.dart';
import 'package:coschon/models/user.dart';
import 'package:dio/dio.dart' as dio;
import 'package:random_string/random_string.dart';
class PhonenumberController extends ResourceController {
  final ManagedContext context;
  final Config config;
  PhonenumberController(this.config, this.context);
  @Operation.post()
  Future<Response> send(@Bind.body() Phonenumber phonenumber) async {
    final confirmation = randomNumeric(6);
    final resches = await dio.Dio().post('https://r5mmz1.api.infobip.com/sms/2/text/advanced', data: {
      "messages": [
        {
          "destinations": [
            {
              "to": '${phonenumber.language}${phonenumber.phonenumber}'
            }
          ],
          "text": "Confirm your phonenumber with $confirmation"
        }
      ]
    }, options: dio.Options(
      headers: {
         'Authorization': 'App ${config.smsApiKey!}'
      }
    ));
    print(phonenumber.token);
    final userQuery = Query<User>(context)
      ..values.confirmPhonenumber = int.parse(confirmation)
      ..values.phonenumber = '${phonenumber.language}${phonenumber.phonenumber}'
      ..where((i) => i.confirmEmail).equalTo(phonenumber.token);
    final user = await userQuery.updateOne();
    print(confirmation);
    return Response.ok("");
  }
}