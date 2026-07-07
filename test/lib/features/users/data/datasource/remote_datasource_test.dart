import 'dart:async';
import 'dart:convert';

import 'package:flutter_assignment/core/network/api_client.dart';
import 'package:flutter_assignment/features/users/data/datasource/remote_datasource.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'remote_datasource_test.mocks.dart';

@GenerateMocks([ApiClient])
void main() {
  late ReqResApiDatasourceImpl reqResApi;
  late MockApiClient mockHttp;

  setUp(() {
    mockHttp = MockApiClient();
    reqResApi = ReqResApiDatasourceImpl(apiClient: mockHttp);
  });

  group('getConcreteNumberTrivia', () {
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

      when(mockHttp.get(any)).thenAnswer((_) async => response);

      // act
      final result = await reqResApi.fetchUser(1);

      // assert
      expect(result.length, 1);
      expect(result.first.userId, 1);
      expect(result.first.firstName, "John");
      verify(mockHttp.get(any)).called(1);
      verifyNoMoreInteractions(mockHttp);
    });

    test('should throw Exception when status code is not 200', () async {
      when(
        mockHttp.get(any),
      ).thenAnswer((_) async => http.Response("Not Found", 404));

      expect(() => reqResApi.fetchUser(1), throwsException);
    });

    test('should throw TimeoutException', () async {
      when(mockHttp.get(any)).thenThrow(TimeoutException("timeout"));

      expect(() => reqResApi.fetchUser(1), throwsA(isA<TimeoutException>()));
    });
  });
}
