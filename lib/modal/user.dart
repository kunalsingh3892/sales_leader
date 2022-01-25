class User {
  int id;
  String name;

  User({this.id, this.name});

  factory User.fromJson(Map<String, dynamic> parsedJson) {
    return User(
      id: parsedJson["id"],
      name: parsedJson["city_name"] as String,

    );
  }
}