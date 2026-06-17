class UserModel {
  final int userId;
  final String firstName;
  final String lastName;
  final String imgUrl;
  final String email;

  UserModel({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.imgUrl,
    required this.email,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      imgUrl: json['avatar'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': userId,
      'first_name': firstName,
      'last_name': lastName,
      'avatar': imgUrl,
      'email': email,
    };
  }
}
