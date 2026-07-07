import 'package:flutter_assignment/features/users/domain/entities/user.dart';
import 'package:flutter_assignment/features/users/domain/repository/repository.dart';
import 'package:flutter_assignment/features/users/domain/usecases/get_user_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'get_user_usecase_test.mocks.dart';

@GenerateMocks([UserRepository])
void main() {
  late MockUserRepository mockUserRepository;
  late GetUserUsecase usecase;

  setUp(() {
    mockUserRepository = MockUserRepository();
    usecase = GetUserUsecase(userRepository: mockUserRepository);
  });

  final users = [
    User(
      userId: 1,
      firstName: 'John',
      lastName: 'Doe',
      imgUrl: '',
      email: 'john@test.com',
    ),
  ];

  group('GetUserUsecase', () {
    test('should return users from repository', () async {
      when(mockUserRepository.getUser(1)).thenAnswer((_) async => users);

      final result = await usecase(1);

      expect(result, users);

      verify(mockUserRepository.getUser(1)).called(1);

      verifyNoMoreInteractions(mockUserRepository);
    });

    test('should rethrow exception when repository throws', () async {
      final exception = Exception('Repository Error');

      when(mockUserRepository.getUser(1)).thenThrow(exception);

      await expectLater(usecase(1), throwsA(same(exception)));

      verify(mockUserRepository.getUser(1)).called(1);

      verifyNoMoreInteractions(mockUserRepository);
    });
  });
}
