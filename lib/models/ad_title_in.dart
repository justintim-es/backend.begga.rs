import 'package:conduit/conduit.dart';

class AdTitleIn extends Serializable {
  String? title;
  String? subtitle;
  String? link;
  String? gla;
  String? country;
  int? ads;

  Map<String, dynamic> asMap() => {
        'title': title,
        'subtitle': subtitle,
        'link': link,
        'country': country,
        'gla': gla,
        'ads': ads
      };
  @override
  void readFromMap(Map<String, dynamic> object) {
    title = object['title'].toString();
    subtitle = object['subtitle'].toString();
    link = object['link'].toString();
    country = object['country'].toString();
    gla = object['gla'].toString();
    ads = int.parse(object['ads'].toString());
  }
}
