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
    if(json['description'] != null) {
      description = json['description'];
    } else {
      description = 'None';
    }
    name = json['name'];
    if(json['phone'] != null) {
      phone = json['phone'];
    } else {
      phone = "None";
    }
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

  bool hasPhoto() {
    print(photo);
    return photo != "None";
  }
}
