class Location {
  late String address;
  late String description;
  late String name;
  late String phone;
  late String photo;
  late double rating;

  Location(
      {this.address = "",
      this.description = "",
      this.name = "",
      this.phone = "",
      this.photo = "",
      this.rating = 0.0});

  Location.fromJson(Map<String, dynamic> json) {
    address = json['address'];
    description = json['description'];
    name = json['name'];
    phone = json['phone'];
    photo = json['photo'];
    try {
      rating = json['rating'];
    } catch (e) {
      rating = 0;
    }
  }

  bool hasDesc() {
    return description != "None";
  }

  bool hasPhone() {
    return phone != "None";
  }
}
