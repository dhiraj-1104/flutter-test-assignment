import 'package:flutter_assignment/features/users/domain/entities/user.dart';
import 'package:flutter_assignment/features/users/domain/usecases/get_user_usecase.dart';
import 'package:flutter_assignment/features/users/presentation/bloc/bloc.dart';
import 'package:flutter_assignment/features/users/presentation/bloc/event.dart';
import 'package:flutter_assignment/features/users/presentation/bloc/state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'bloc_test.mocks.dart';

@GenerateMocks([GetUserUsecase])
void main() {
  late MockGetUserUsecase mockGetUserUsecase;
  late UserBloc bloc;

  setUp(() {
    mockGetUserUsecase = MockGetUserUsecase();

    bloc = UserBloc(getUserUsecase: mockGetUserUsecase);
  });

  final users = [
    User(
      userId: 1,
      firstName: 'John',
      lastName: 'Doe',
      imgUrl: '',
      email: 'john@test.com',
    ),
    User(
      userId: 2,
      firstName: 'lane',
      lastName: 'Doe',
      imgUrl: '',
      email: 'lane@test.com',
    ),
  ];

  test('initial state should be UserInitial', () {
    expect(bloc.state, isA<UserInitial>());
  });

  group('GetUserEvent', () {
    test('should call usecase', () async {
      when(mockGetUserUsecase(1)).thenAnswer((_) async => users);

      bloc.add(GetUserEvent());

      await untilCalled(mockGetUserUsecase(1));

      verify(mockGetUserUsecase(1)).called(1);
    });

    test('should emit [Loading, Loaded]', () async {
      when(mockGetUserUsecase(1)).thenAnswer((_) async => users);

      expectLater(
        bloc.stream,
        emitsInOrder([isA<UserLoading>(), isA<UserLoaded>()]),
      );

      bloc.add(GetUserEvent());
    });

    test('should emit [Loading, Error]', () async {
      when(mockGetUserUsecase(1)).thenThrow(Exception('Server Error'));

      expectLater(
        bloc.stream,
        emitsInOrder([isA<UserLoading>(), isA<UserError>()]),
      );

      bloc.add(GetUserEvent());
    });
  });

  group('LoadUserEvent', () {
    test('should load next page', () async {
      when(mockGetUserUsecase(1)).thenAnswer((_) async => users);

      when(mockGetUserUsecase(2)).thenAnswer((_) async => users);

      bloc.add(GetUserEvent());

      await untilCalled(mockGetUserUsecase(1));

      bloc.add(LoadUserEvent());

      await untilCalled(mockGetUserUsecase(2));

      verify(mockGetUserUsecase(2)).called(1);
    });
  });

  group('FilterUserEvent', () {
    test('should filter users', () async {
      when(mockGetUserUsecase(1)).thenAnswer((_) async => users);

      bloc.add(GetUserEvent());

      await untilCalled(mockGetUserUsecase(1));

      expectLater(
        bloc.stream,
        emitsThrough(
          predicate<UserLoaded>(
            (state) =>
                state.users.length == 1 &&
                state.users.first.firstName == "John",
          ),
        ),
      );

      bloc.add(FilterUserEvent(query: 'jo'));
    });

    test('should emit loaded even if no user matches', () async {
      when(mockGetUserUsecase(1)).thenAnswer((_) async => users);

      bloc.add(GetUserEvent());

      await untilCalled(mockGetUserUsecase(1));

      expectLater(bloc.stream, emitsThrough(isA<UserLoaded>()));

      bloc.add(FilterUserEvent(query: 'xyz'));
    });
  });
}
