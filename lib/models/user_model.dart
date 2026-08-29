class UserModel {
  String name;
  String mobile;
  String village;
  String landArea;
  String crop;
  String password;

  UserModel({
    required this.name,
    required this.mobile,
    required this.village,
    required this.landArea,
    required this.crop,
    required this.password,
  });

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "mobile": mobile,
      "village": village,
      "landArea": landArea,
      "crop": crop,
      "password": password,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map["name"] ?? "",
      mobile: map["mobile"] ?? "",
      village: map["village"] ?? "",
      landArea: map["landArea"] ?? "",
      crop: map["crop"] ?? "",
      password: map["password"] ?? "",
    );
  }
}