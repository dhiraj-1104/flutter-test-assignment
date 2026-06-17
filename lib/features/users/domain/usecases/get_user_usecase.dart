import 'package:flutter_assignment/features/users/domain/entities/user.dart';
import 'package:flutter_assignment/features/users/domain/repository/repository.dart';

class GetUserUsecase {
  final UserRepository _userRepository;

  GetUserUsecase({required this._userRepository});
  Future<List<User>> call(int page) async {
    return await _userRepository.getUser(page);
  }
}
