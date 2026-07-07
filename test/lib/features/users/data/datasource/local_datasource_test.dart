import 'package:flutter_assignment/features/users/data/datasource/local_datasource.dart';
import 'package:flutter_assignment/features/users/data/models/user_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'local_datasource_test.mocks.dart';

@GenerateMocks([Box])
void main() {
  late MockBox mockBox;
  late HiveDatasoureImpl datasource;

  setUp(() {
    mockBox = MockBox();
    datasource = HiveDatasoureImpl(box: mockBox);
  });

  group('cacheUsers', () {
    final users = [
      UserModel(
        email: 'john@test.com',
        firstName: 'John',
        imgUrl: "",
        lastName: "Doe",
        userId: 1,
      ),
    ];

    final date = DateTime.now();

    test('should cache users and cache time', () async {
      when(mockBox.put(any, any)).thenAnswer((_) async {});

      await datasource.cacheUsers(users, date);

      verify(
        mockBox.put(
          HiveDatasoureImpl.usersKey,
          users.map((e) => e.toJson()).toList(),
        ),
      ).called(1);

      verify(
        mockBox.put(HiveDatasoureImpl.cacheTimeKey, date.toString()),
      ).called(1);

      verifyNoMoreInteractions(mockBox);
    });

    test('should rethrow exception when put fails', () async {
      when(mockBox.put(any, any)).thenThrow(Exception('Hive Error'));

      expect(() => datasource.cacheUsers(users, date), throwsException);
    });
  });

  group('getCachedUsers', () {
    final users = [
      UserModel(
        email: 'john@test.com',
        firstName: 'John',
        imgUrl: "",
        lastName: "Doe",
        userId: 1,
      ),
    ];

    final jsonUsers = users.map((e) => e.toJson()).toList();

    test('should return empty list when cache time is null', () async {
      // Arrange
      when(mockBox.get(HiveDatasoureImpl.cacheTimeKey)).thenReturn(null);

      // Act
      final result = await datasource.getCachedUsers();

      // Assert
      expect(result, isEmpty);
    });

    test(
      'should delete cache and return empty list if cache expired',
      () async {
        // Arrange
        final expiredDate = DateTime.now().subtract(const Duration(hours: 3));
        when(mockBox.get(HiveDatasoureImpl.usersKey)).thenReturn("");
        when(
          mockBox.get(HiveDatasoureImpl.cacheTimeKey),
        ).thenReturn(expiredDate.toString());

        when(mockBox.delete(any)).thenAnswer((_) async {});

        // Act
        final result = await datasource.getCachedUsers();

        // Assert
        expect(result, isEmpty);

        verify(mockBox.delete(HiveDatasoureImpl.cacheTimeKey)).called(1);
        verify(mockBox.delete(HiveDatasoureImpl.usersKey)).called(1);
      },
    );

    test('should return empty list when cached users are null', () async {
      // Arrange
      when(
        mockBox.get(HiveDatasoureImpl.cacheTimeKey),
      ).thenReturn(DateTime.now().toString());

      when(mockBox.get(HiveDatasoureImpl.usersKey)).thenReturn(null);

      // Act
      final result = await datasource.getCachedUsers();

      // Assert
      expect(result, isEmpty);
    });

    test('should return cached users when cache is valid', () async {
      // Arrange
      when(mockBox.get(HiveDatasoureImpl.usersKey)).thenReturn(jsonUsers);
      when(
        mockBox.get(HiveDatasoureImpl.cacheTimeKey),
      ).thenReturn(DateTime.now().toString());

      // Act
      final result = await datasource.getCachedUsers();

      // Assert
      expect(result.length, users.length);
      expect(result.first.email, equals(users.first.email));
    });

    test('should throws exception if the hive error occurs', () async {
      // Arrange
      when(mockBox.get(any)).thenThrow(Exception('Hive Error'));

      // Act + Assert
      expect(() => datasource.getCachedUsers(), throwsException);
    });
  });
}
