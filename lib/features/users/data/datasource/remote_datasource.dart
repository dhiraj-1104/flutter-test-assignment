import 'dart:async';
import 'dart:convert';

import 'package:flutter_assignment/core/constants/api_constants.dart';
import 'package:flutter_assignment/core/helpers/app_logger.dart';
import 'package:flutter_assignment/core/network/api_client.dart';
import 'package:flutter_assignment/features/users/data/models/user_model.dart';

abstract class RemoteDatasource {
  Future<List<UserModel>> fetchUser(int page);
}

class ReqResApiDatasourceImpl extends RemoteDatasource {
  final ApiClient _apiClient;
  ReqResApiDatasourceImpl({required this._apiClient});
  @override
  Future<List<UserModel>> fetchUser(int page) async {
    try {
      final response = await _apiClient.get(
        Uri.parse("${ApiConstants.baseUrl}/users?per_page=15&page=$page"),
      );

      AppLogger.debug("The API Response is :${response.body}");

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final List<dynamic> usersList = jsonData['data'];
        return usersList.map((e) => UserModel.fromJson(e)).toList();
      }
      AppLogger.debug("The API Status code is ${response.statusCode}");
      throw Exception("Something Went Wrong!!");
    } on TimeoutException catch (e, stackTrace) {
      AppLogger.error("Timeout Exception", error: e, stackTrace: stackTrace);
      throw TimeoutException("Server taking to much time to response");
    } catch (e, stackTrace) {
      AppLogger.error(
        "Error in the APIRemoteDatasource",
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
