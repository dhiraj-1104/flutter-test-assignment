import 'package:flutter_assignment/core/errors/exceptions.dart';
import 'package:flutter_assignment/core/helpers/app_logger.dart';
import 'package:flutter_assignment/core/network/network_info.dart';
import 'package:flutter_assignment/features/users/data/datasource/local_datasource.dart';
import 'package:flutter_assignment/features/users/data/datasource/remote_datasource.dart';
import 'package:flutter_assignment/features/users/domain/entities/user.dart';
import 'package:flutter_assignment/features/users/domain/repository/repository.dart';

class RespositoriesImpl extends UserRepository {
  final RemoteDatasource _remoteDatasource;
  final LocalDatasource _localDatasource;
  final NetworkConnectivity _connectivity;

  RespositoriesImpl({
    required this._remoteDatasource,
    required this._connectivity,
    required this._localDatasource,
  });

  @override
  Future<List<User>> getUser(int page) async {
    try {
      if (!await _connectivity.isConnected) {
        AppLogger.info("The Device is not Connected to internet");
        AppLogger.info("Trying to fetch data from local cache");

        final users = await _localDatasource.getCachedUsers();

        if (users.isEmpty) {
          AppLogger.info("Data is not available in the cache");
          throw UnableToFetchUser(msg: "You are not connected to network");
        }

        AppLogger.info("Returning cached data");
        return users.map((e) => User.fromModel(e)).toList();
      } else {
        try {
          AppLogger.info(
            "The Device is connected to a Network Fetching data from internet",
          );

          final users = await _remoteDatasource.fetchUser(page);

          AppLogger.info("Caching the fetched Data");
          if (page > 1) {
            final cachedUsers = await _localDatasource.getCachedUsers();
            final updatedCachedUsers = [...cachedUsers, ...users];
            await _localDatasource.cacheUsers(users, DateTime.now());
            AppLogger.info("Successfully Cached the user Data");
            return updatedCachedUsers.map((e) => User.fromModel(e)).toList();
          } else {
            await _localDatasource.cacheUsers(users, DateTime.now());

            AppLogger.info("Successfully Cached the user Data");

            return users.map((e) => User.fromModel(e)).toList();
          }
        } catch (e) {
          AppLogger.error("Server request failed. Trying cache.", error: e);

          final cachedUsers = await _localDatasource.getCachedUsers();

          if (cachedUsers.isNotEmpty) {
            AppLogger.info("Returning cached users because API failed");

            return cachedUsers.map((e) => User.fromModel(e)).toList();
          }

          rethrow;
        }
      }
    } catch (e, stackTrace) {
      AppLogger.error(
        "ERROR occurs in repository IMPL",
        error: e,
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }

  // @override
  // Future<List<User>> getUser(int page) async {
  //   try {
  //     if (!await _connectivity.isConnected) {
  //       AppLogger.info("The Device is not Connected to internet");
  //       AppLogger.info("Trying to fetch data from local cache");
  //       final users = _localDatasource.getCachedUsers();
  //       if (users == null || users.isEmpty) {
  //         AppLogger.info("Data is not available in the cache");
  //         throw UnableToFetchUser(msg: "You are not connected to network");
  //       }
  //       AppLogger.info("Returning cached data");
  //       return users.map((e) => User.fromModel(e)).toList();
  //     } else {
  //       AppLogger.info(
  //         "The Device is connected to a Network Fetching data from internet",
  //       );
  //       List<UserModel> users = await _remoteDatasource.fetchUser(page);
  //       AppLogger.info("Caching the fetched Data");
  //       _localDatasource.cacheUsers(users, DateTime.now());
  //       AppLogger.info("Successfully Cahched the user Data");
  //       return users.map((e) => User.fromModel(e)).toList();
  //     }
  //   } catch (e, stackTrace) {
  //     AppLogger.error(
  //       "ERROR occurs in repository IMPL",
  //       error: e,
  //       stackTrace: stackTrace,
  //     );

  //     rethrow;
  //   }
  // }
}
