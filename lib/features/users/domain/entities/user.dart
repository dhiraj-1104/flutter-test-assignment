import 'package:flutter_assignment/features/users/data/models/user_model.dart';

class User {
  final int userId;
  final String firstName;
  final String lastName;
  final String imgUrl;
  final String email;

  User({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.imgUrl,
    required this.email,
  });

  factory User.fromModel(UserModel model) {
    return User(
      userId: model.userId,
      firstName: model.firstName,
      lastName: model.lastName,
      imgUrl: model.imgUrl,
      email: model.email,
    );
  }

  UserModel toModel() {
    return UserModel(
      email: email,
      firstName: firstName,
      imgUrl: imgUrl,
      lastName: lastName,
      userId: userId,
    );
  }
}
