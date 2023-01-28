import 'package:faq_helper/models/autocompleteRes.dart';
import 'package:faq_helper/secret.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class NetworkUtility {
  static Future<Map<String, dynamic>> fetchUrl(Uri uri, {Map<String, String>? headers}) async {
    try {
      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        // print(response.body);
        return convert.jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (e) {
      print(e.toString());
    }
    return {};
  }

  static Future<List<PlacesAutocompletion>> getAutocompletions(String query) async {
    Uri uri = Uri.https(
      'maps.googleapis.com',
      'maps/api/place/autocomplete/json',
      {'input': query, 'key': GOOGLE_PLACES_API_KEY},
    );
    Map res = (await fetchUrl(uri));
    if(res.isNotEmpty) {
      if(res['predictions'] != null) {
        return PlacesAutocompletion.listFromJson(res['predictions']);
      }
    }
    print("Autocompletions returned null");
    return [];
  }
}
