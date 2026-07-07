import 'package:flutter_assignment/core/errors/exceptions.dart';
import 'package:flutter_assignment/core/network/network_info.dart';
import 'package:flutter_assignment/features/users/data/datasource/local_datasource.dart';
import 'package:flutter_assignment/features/users/data/datasource/remote_datasource.dart';
import 'package:flutter_assignment/features/users/data/models/user_model.dart';
import 'package:flutter_assignment/features/users/data/repositories/respositories_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'repository_impl_test.mocks.dart';

@GenerateMocks([RemoteDatasource, LocalDatasource, NetworkConnectivity])
void main() {
  late MockRemoteDatasource mockRemoteDatasource;
  late MockLocalDatasource mockLocalDatasource;
  late MockNetworkConnectivity mockConnectivity;
  late RespositoriesImpl repository;

  setUp(() {
    mockRemoteDatasource = MockRemoteDatasource();

    mockLocalDatasource = MockLocalDatasource();

    mockConnectivity = MockNetworkConnectivity();

    repository = RespositoriesImpl(
      remoteDatasource: mockRemoteDatasource,
      localDatasource: mockLocalDatasource,
      connectivity: mockConnectivity,
    );
  });

  final users = [
    UserModel(
      userId: 1,
      firstName: "John",
      lastName: "Doe",
      email: "john@test.com",
      imgUrl: "",
    ),
  ];

  group('getUser', () {
    test(
      'should return cached users when device is offline and cache exists',
      () async {
        when(mockConnectivity.isConnected).thenAnswer((_) async => false);

        when(
          mockLocalDatasource.getCachedUsers(),
        ).thenAnswer((_) async => users);

        final result = await repository.getUser(1);

        expect(result.length, 1);
        expect(result.first.userId, users.first.userId);
        verify(mockConnectivity.isConnected);
        verify(mockLocalDatasource.getCachedUsers());
        verifyNever(mockRemoteDatasource.fetchUser(any));
      },
    );
  });

  test(
    'should throw UnableToFetchUser when device is offline and cache is empty',
    () async {
      when(mockConnectivity.isConnected).thenAnswer((_) async => false);

      when(mockLocalDatasource.getCachedUsers()).thenAnswer((_) async => []);

      await expectLater(
        repository.getUser(1),
        throwsA(isA<UnableToFetchUser>()),
      );

      verify(mockConnectivity.isConnected).called(1);
      verify(mockLocalDatasource.getCachedUsers()).called(1);

      verifyNever(mockRemoteDatasource.fetchUser(any));
    },
  );

  test(
    'should fetch users from remote datasource and cache them when online',
    () async {
      when(mockConnectivity.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDatasource.fetchUser(1)).thenAnswer((_) async => users);
      when(mockLocalDatasource.cacheUsers(any, any)).thenAnswer((_) async {});

      final result = await repository.getUser(1);

      expect(result.length, users.length);
      expect(result.first.userId, users.first.userId);
      verify(mockConnectivity.isConnected).called(1);
      verify(mockRemoteDatasource.fetchUser(1)).called(1);
      verify(mockLocalDatasource.cacheUsers(users, any)).called(1);
      verifyNever(mockLocalDatasource.getCachedUsers());
    },
  );
  test(
    'should fetch users from remote datasource and cache them when online',
    () async {
      when(mockConnectivity.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDatasource.fetchUser(1)).thenAnswer((_) async => users);
      when(mockLocalDatasource.cacheUsers(any, any)).thenAnswer((_) async {});

      final result = await repository.getUser(1);

      expect(result.length, users.length);
      expect(result.first.userId, users.first.userId);
      verify(mockConnectivity.isConnected).called(1);
      verify(mockRemoteDatasource.fetchUser(1)).called(1);
      verify(mockLocalDatasource.cacheUsers(users, any)).called(1);
      verifyNever(mockLocalDatasource.getCachedUsers());
    },
  );

  test('should append users to cache when page is greater than 1', () async {
    final cachedUsers = [
      UserModel(
        userId: 1,
        firstName: 'John',
        lastName: 'Doe',
        email: 'john@test.com',
        imgUrl: '',
      ),
    ];

    final remoteUsers = [
      UserModel(
        userId: 2,
        firstName: 'Jane',
        lastName: 'Smith',
        email: 'jane@test.com',
        imgUrl: '',
      ),
    ];

    when(mockConnectivity.isConnected).thenAnswer((_) async => true);

    when(
      mockRemoteDatasource.fetchUser(2),
    ).thenAnswer((_) async => remoteUsers);

    when(
      mockLocalDatasource.getCachedUsers(),
    ).thenAnswer((_) async => cachedUsers);

    when(mockLocalDatasource.cacheUsers(any, any)).thenAnswer((_) async {});

    final result = await repository.getUser(2);

    expect(result.length, 2);

    expect(result.first.userId, 1);

    expect(result.last.userId, 2);

    verify(mockRemoteDatasource.fetchUser(2)).called(1);

    verify(mockLocalDatasource.getCachedUsers()).called(1);

    verify(
      mockLocalDatasource.cacheUsers([...cachedUsers, ...remoteUsers], any),
    ).called(1);
  });

  test(
    'should return cached users when remote datasource throws exception',
    () async {
      when(mockConnectivity.isConnected).thenAnswer((_) async => true);

      when(
        mockRemoteDatasource.fetchUser(1),
      ).thenThrow(Exception('Server Error'));

      when(mockLocalDatasource.getCachedUsers()).thenAnswer((_) async => users);

      final result = await repository.getUser(1);

      expect(result.length, users.length);

      expect(result.first.userId, users.first.userId);

      verify(mockConnectivity.isConnected).called(1);

      verify(mockRemoteDatasource.fetchUser(1)).called(1);

      verify(mockLocalDatasource.getCachedUsers()).called(1);

      verifyNever(mockLocalDatasource.cacheUsers(any, any));
    },
  );

  test(
    'should rethrow exception when remote fails and cache is empty',
    () async {
      final exception = Exception('Server Error');

      when(mockConnectivity.isConnected).thenAnswer((_) async => true);

      when(mockRemoteDatasource.fetchUser(1)).thenThrow(exception);

      when(mockLocalDatasource.getCachedUsers()).thenAnswer((_) async => []);

      await expectLater(repository.getUser(1), throwsA(same(exception)));

      verify(mockConnectivity.isConnected).called(1);

      verify(mockRemoteDatasource.fetchUser(1)).called(1);

      verify(mockLocalDatasource.getCachedUsers()).called(1);

      verifyNever(mockLocalDatasource.cacheUsers(any, any));
    },
  );
}
