import 'dart:convert';

class PlacesAutocompletion {
  String? description;

  // List<MatchedSubstrings>? matchedSubstrings;
  String? placeId;
  String? reference;
  String? title;
  String? address;

  PlacesAutocompletion(
      {this.description,
      // this.matchedSubstrings,
      this.placeId,
      this.reference,
      this.title,
      this.address});

  PlacesAutocompletion.fromJson(Map<String, dynamic> json) {
    description = json['description'];
    placeId = json['place_id'];
    reference = json['reference'];
    if (json['structured_formatting'] != null) {
      title = json['structured_formatting']['main_text'];
      address = json['structured_formatting']['secondary_text'];
    }
  }

  static List<PlacesAutocompletion> listFromJson(
      List<dynamic> jsonList) {
    List<PlacesAutocompletion> res = [];
    for (int i = 0; i < jsonList.length; i++) {
      res.add(PlacesAutocompletion.fromJson(jsonList[i] as Map<String, dynamic>));
    }
    return res;
  }
}