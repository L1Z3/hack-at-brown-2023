import 'package:faq_helper/models/autocompleteRes.dart';
import 'package:faq_helper/secret.dart';
import 'package:faq_helper/models/location.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class NetworkUtility {
  static Future<Map<String, dynamic>> fetchUrl(Uri uri,
      {Map<String, String>? headers}) async {
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

  static Future<List<PlacesAutocompletion>> getAutocompletions(
      String query) async {
    Uri uri = Uri.https(
      'maps.googleapis.com',
      'maps/api/place/autocomplete/json',
      {'input': query, 'key': GOOGLE_PLACES_API_KEY},
    );
    Map res = (await fetchUrl(uri));
    if (res.isNotEmpty) {
      if (res['predictions'] != null) {
        return PlacesAutocompletion.listFromJson(res['predictions']);
      }
    }
    print("Autocompletions returned null");
    return [];
  }

  static Future<Location> getLocationInfo(String placeId) async {
    final http.Response response = await http.post(
      Uri.parse('http://cs300.eastus2.cloudapp.azure.com:25565/get_place_info'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: convert.jsonEncode(
        <String, dynamic>{
          "place_id": placeId,
          "max_reviews": 20,
          "password": FLASK_PASSWORD
        },
      ),
    );

    if (response.statusCode == 200) {
      return Location.fromJson(convert.jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch response. ${response.body}');
    }
  }

  static Future<String> getAnswer(
      String placeId, int maxReviews, String question) async {
    final http.Response response = await http.post(
      Uri.parse('http://cs300.eastus2.cloudapp.azure.com:25565/ask_question'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: convert.jsonEncode(
        <String, dynamic>{
          "place_id": placeId,
          "max_reviews": maxReviews,
          "password": FLASK_PASSWORD,
          "question": question
        },
      ),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> res =
          convert.jsonDecode(response.body) as Map<String, dynamic>;
      if (res['answer'] != null) {
        return res['answer'];
      }
      return "";
    } else {
      throw Exception('Failed to get answer. ${response.body}');
    }
  }

  static Future<String> getSummary(String placeId, int maxReviews) async {
    final http.Response response = await http.post(
      Uri.parse('http://cs300.eastus2.cloudapp.azure.com:25565/get_summary'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: convert.jsonEncode(
        <String, dynamic>{
          "place_id": placeId,
          "max_reviews": maxReviews,
          "password": FLASK_PASSWORD,
        },
      ),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> res =
          convert.jsonDecode(response.body) as Map<String, dynamic>;
      if (res['summary'] != null) {
        return res['summary'];
      }
      return "";
    } else {
      throw Exception('Failed to get answer. ${response.body}');
    }
  }
}
