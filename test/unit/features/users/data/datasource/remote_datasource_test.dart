import 'dart:async';

import 'package:flutter_assignment/core/constants/api_constants.dart';
import 'package:flutter_assignment/core/network/api_client.dart';
import 'package:flutter_assignment/features/users/data/datasource/remote_datasource.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

class MockHttpClient extends Mock implements ApiClient {}

class FakeUri extends Fake implements Uri {}

void main() {
  late MockHttpClient mockClient;
  late RemoteDatasourceImpl datasource;

  setUpAll(() {
    registerFallbackValue(FakeUri());
  });
  setUp(() {
    mockClient = MockHttpClient();
    datasource = RemoteDatasourceImpl(apiClient: mockClient);
  });

  test('should return users when api returns 200', () async {
    when(() => mockClient.get(any())).thenAnswer(
      (_) async => http.Response('''
       
           [
            {
              "id": 1,
              "login": "John",
              "html_url" : "https://github.com/jnewland",
              "avatar_url" : "https://avatars.githubusercontent.com/u/47?v=4"
             
            }
          ]
    
        ''', 200),
    );
    final result = await datasource.fetchUser();

    expect(result.length, 1);
    expect(result.first.userName, 'John');
    expect(result.first.userId, 1);
    expect(result.first.gitHubUrl, 'https://github.com/jnewland');
    expect(
      result.first.avatarUrl,
      'https://avatars.githubusercontent.com/u/47?v=4',
    );
  });

  group('fetchUser', () {
    test('should return List<UserModel> when status code is 200', () async {
      when(() => mockClient.get(any())).thenAnswer(
        (_) async => http.Response('''
            [
              {
                "id": 1,
                "login": "John"
               
              }
            ]
            ''', 200),
      );

      final result = await datasource.fetchUser();

      expect(result.length, 1);
      expect(result.first.userName, 'John');

      verify(
        () => mockClient.get(Uri.parse("${ApiConstants.baseUrl}/users")),
      ).called(1);
    });

    test('should return empty list when status code is not 200', () async {
      when(
        () => mockClient.get(any()),
      ).thenAnswer((_) async => http.Response('Server Error', 500));

      final result = await datasource.fetchUser();

      expect(result, isEmpty);
    });

    test('should throw TimeoutException when request times out', () async {
      when(
        () => mockClient.get(any()),
      ).thenThrow(TimeoutException('Connection timeout'));

      expect(() => datasource.fetchUser(), throwsA(isA<TimeoutException>()));
    });
  });
}
