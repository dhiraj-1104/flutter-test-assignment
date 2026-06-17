import 'package:flutter_assignment/core/helpers/app_logger.dart';
import 'package:flutter_assignment/features/users/data/models/user_model.dart';
import 'package:hive_flutter/adapters.dart';

abstract class LocalDatasource {
  Future<void> cacheUsers(List<UserModel> users, DateTime date);
  Future<List<UserModel>> getCachedUsers();
}

class HiveDatasoureImpl extends LocalDatasource {
  final Box _box;
  static const String usersKey = 'users';
  static const String cacheTimeKey = 'time';
  HiveDatasoureImpl({required this._box});
  @override
  Future<List<UserModel>> getCachedUsers() async {
    try {
      final data = _box.get(usersKey);
      final dateString = _box.get(cacheTimeKey);
      if (dateString == null) {
        return [];
      }
      final dateFormat = DateTime.parse(dateString);
      final difference = DateTime.now().difference(dateFormat);
      if (difference.inHours > 2) {
        await _box.delete(cacheTimeKey);
        await _box.delete(usersKey);
        return [];
      }
      if (data == null) {
        AppLogger.info('cache data is empty');
        return [];
      }

      List<UserModel> users = (data as List)
          .map(
            (user) =>
                UserModel.fromJson(Map<String, dynamic>.from(user as Map)),
          )
          .toList();
      AppLogger.debug("The users model is: $users");
      return users;
    } catch (e, stackTrace) {
      AppLogger.error(
        "ERROR ocurs in HiveDataSource",
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<void> cacheUsers(List<UserModel> users, DateTime date) async {
    try {
      final jsonUserList = users.map((user) => user.toJson()).toList();
      AppLogger.info('UserModel converted to json successfully');
      await _box.put(usersKey, jsonUserList);
      await _box.put(cacheTimeKey, date.toString());
      AppLogger.info('Users cache successfully');
    } catch (e, stackTrace) {
      AppLogger.error(
        "The ERROR Ocuurs in the cacheUsers in HiveDataSourceImpl",
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
