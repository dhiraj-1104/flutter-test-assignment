import 'dart:async';
import 'dart:convert';

import 'package:flutter_assignment/core/constants/api_constants.dart';
import 'package:flutter_assignment/core/helpers/app_logger.dart';
import 'package:flutter_assignment/core/network/api_client.dart';
import 'package:flutter_assignment/features/users/data/models/user_model.dart';
import 'package:http/http.dart' as http;

abstract class RemoteDatasource {
  Future<List<UserModel>> fetchUser(int page);
}

class MockApi extends RemoteDatasource {
  @override
  Future<List<UserModel>> fetchUser(int page) async {
    AppLogger.info("MockApi called for page $page");
    if (page >= 3) {
      return [];
    }
    try {
      final response = http.Response(
        jsonEncode({
          "data": [
            {
              "id": 7,
              "email": "michael.lawson@reqres.in",
              "first_name": "Michael",
              "last_name": "Lawson",
              "avatar": "https://reqres.in/img/faces/7-image.jpg",
            },
            {
              "id": 8,
              "email": "lindsay.ferguson@reqres.in",
              "first_name": "Lindsay",
              "last_name": "Ferguson",
              "avatar": "https://reqres.in/img/faces/8-image.jpg",
            },
            {
              "id": 9,
              "email": "tobias.funke@reqres.in",
              "first_name": "Tobias",
              "last_name": "Funke",
              "avatar": "https://reqres.in/img/faces/9-image.jpg",
            },
            {
              "id": 10,
              "email": "byron.fields@reqres.in",
              "first_name": "Byron",
              "last_name": "Fields",
              "avatar": "https://reqres.in/img/faces/10-image.jpg",
            },
            {
              "id": 11,
              "email": "george.edwards@reqres.in",
              "first_name": "George",
              "last_name": "Edwards",
              "avatar": "https://reqres.in/img/faces/11-image.jpg",
            },
            {
              "id": 12,
              "email": "rachel.howell@reqres.in",
              "first_name": "Rachel",
              "last_name": "Howell",
              "avatar": "https://reqres.in/img/faces/12-image.jpg",
            },
          ],
        }),
        200,
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

class ReqResApiDatasourceImpl extends RemoteDatasource {
  final ApiClient _apiClient;
  ReqResApiDatasourceImpl({required this._apiClient});
  @override
  Future<List<UserModel>> fetchUser(int page) async {
    try {
      final response = await _apiClient.get(
        Uri.parse("${ApiConstants.baseUrl}/users?per_page=8&page=$page"),
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
