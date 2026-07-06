import 'package:flutter_assignment/features/users/data/models/user_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserModel', () {
    final userModel = UserModel(
      email: 'john@test.com',
      firstName: 'John',
      lastName: 'Doe',
      imgUrl: 'https://test.com/avatar.png',
      userId: 1,
    );

    final jsonMap = {
      'id': 1,
      'first_name': 'John',
      'last_name': 'Doe',
      'avatar': 'https://test.com/avatar.png',
      'email': 'john@test.com',
    };

    test('should create UserModel from constructor', () {
      expect(userModel.userId, 1);
      expect(userModel.firstName, 'John');
      expect(userModel.lastName, 'Doe');
      expect(userModel.imgUrl, 'https://test.com/avatar.png');
      expect(userModel.email, 'john@test.com');
    });

    test('should return UserModel from JSON', () {
      final result = UserModel.fromJson(jsonMap);

      expect(result.userId, 1);
      expect(result.firstName, 'John');
      expect(result.lastName, 'Doe');
      expect(result.imgUrl, 'https://test.com/avatar.png');
      expect(result.email, 'john@test.com');
    });

    test('should convert UserModel to JSON', () {
      final result = userModel.toJson();

      expect(result, jsonMap);
    });

    test('should convert JSON to model and back to JSON', () {
      final model = UserModel.fromJson(jsonMap);

      expect(model.toJson(), jsonMap);
    });
  });
}
