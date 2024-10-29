class UserModel {
  int? id;
  String? name;
  String? email;
  String? phone;
  String? gender;
  String? department;
  String? faculty;
  String? position;
  String? image;
  String? token;

  UserModel({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.gender,
    this.department,
    this.faculty,
    this.position,
    this.image,
    this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      gender: json['gender'],
      department: json['department'],
      faculty: json['faculty'],
      position: json['position'],
      image: json['image'],
      token: json['token'],
    );
  }
}
