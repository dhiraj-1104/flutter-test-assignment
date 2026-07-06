import 'dart:async';
import 'dart:convert';

import 'package:flutter_assignment/core/network/api_client.dart';
import 'package:flutter_assignment/features/users/data/datasource/remote_datasource.dart';
import 'package:flutter_assignment/features/users/data/models/user_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../../../fixtures/fixture_reader.dart';
import 'remote_datasource_test.mocks.dart';

@GenerateMocks([ApiClient])
void main() {
  late ReqResApiDatasourceImpl _reqResApi;
  late MockApiClient _mockHttp;

  setUp(() {
    _mockHttp = MockApiClient();
    _reqResApi = ReqResApiDatasourceImpl(apiClient: _mockHttp);
  });

  // void setUpMockHttpClientSuccess200() {
  //   when(
  //     _mockHttp.get(any),
  //   ).thenAnswer((_) async => http.Response(fixture('user.json'), 200));
  // }

  // void setUpMockHttpClientFailure404() {
  //   when(
  //     _mockHttp.get(any),
  //   ).thenAnswer((_) async => http.Response('Something went wrong', 404));
  // }

  group('getConcreteNumberTrivia', () {
    // int page = 1;
    // final userModel = UserModel.fromJson(jsonDecode(fixture('user.json')));
    test('should return list of users when status code is 200', () async {
      // arrange

      final response = http.Response(
        jsonEncode({
          "data": [
            {
              "id": 1,
              "email": "abc@test.com",
              "first_name": "John",
              "last_name": "Doe",
              "avatar": "avatar.jpg",
            },
          ],
        }),
        200,
      );

      when(_mockHttp.get(any)).thenAnswer((_) async => response);

      // act

      final result = await _reqResApi.fetchUser(1);

      // assert

      expect(result.length, 1);

      expect(result.first.userId, 1);

      expect(result.first.firstName, "John");

      verify(_mockHttp.get(any)).called(1);

      verifyNoMoreInteractions(_mockHttp);
    });

    test('should throw Exception when status code is not 200', () async {
      when(
        _mockHttp.get(any),
      ).thenAnswer((_) async => http.Response("Not Found", 404));

      expect(() => _reqResApi.fetchUser(1), throwsException);
    });

    test('should throw TimeoutException', () async {
      when(_mockHttp.get(any)).thenThrow(TimeoutException("timeout"));

      expect(() => _reqResApi.fetchUser(1), throwsA(isA<TimeoutException>()));
    });
  });
}
