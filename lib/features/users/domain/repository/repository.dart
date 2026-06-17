import 'package:flutter_assignment/features/users/domain/entities/user.dart';

abstract class UserRepository {
  Future<List<User>> getUser(int page);
}
