class UserModel {
  String name;
  String email;
  String phone;
  String address;
  String farmName;
  String farmLocation;
  String farmSize;
  String mainCrop;
  String soilType;
  String profileImage;

  UserModel({
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.farmName,
    required this.farmLocation,
    required this.farmSize,
    required this.mainCrop,
    required this.soilType,
    required this.profileImage,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json["name"] ?? "",
      email: json["email"] ?? "",
      phone: json["phone"] ?? "",
      address: json["address"] ?? "",
      farmName: json["farmName"] ?? "",
      farmLocation: json["farmLocation"] ?? "",
      farmSize: json["farmSize"] ?? "",
      mainCrop: json["mainCrop"] ?? "",
      soilType: json["soilType"] ?? "",
      profileImage: json["profileImage"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "email": email,
      "phone": phone,
      "address": address,
      "farmName": farmName,
      "farmLocation": farmLocation,
      "farmSize": farmSize,
      "mainCrop": mainCrop,
      "soilType": soilType,
      "profileImage": profileImage,
    };
  }
}
