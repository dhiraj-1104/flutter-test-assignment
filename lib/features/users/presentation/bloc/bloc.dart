import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_assignment/core/helpers/app_logger.dart';
import 'package:flutter_assignment/features/users/domain/entities/user.dart';
import 'package:flutter_assignment/features/users/domain/usecases/get_user_usecase.dart';
import 'package:flutter_assignment/features/users/presentation/bloc/event.dart';
import 'package:flutter_assignment/features/users/presentation/bloc/state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final GetUserUsecase _getUserUsecase;
  int currentPage = 1;
  List<User> usersList = [];
  UserBloc({required this._getUserUsecase}) : super(UserInitial()) {
    on<GetUserEvent>((event, emit) async {
      try {
        AppLogger.info("Emitted Loading State");
        emit(UserLoading());

        currentPage = 1;
        AppLogger.debug("Current Page $currentPage");
        final users = await _getUserUsecase(currentPage);
        currentPage++;

        AppLogger.debug(
          "The Fetched user are as follow: ${users.map((e) {
            return e.firstName;
          })}",
        );
        AppLogger.debug("fetched user successfully");
        usersList = [...users];
        emit(
          UserLoaded(users: usersList, isFetching: false, hasReachedMax: false),
        );
        AppLogger.info("Emitted Success State");
      } catch (e, s) {
        emit(UserError(msg: e.toString()));
        AppLogger.error("Emitted Error State", error: e, stackTrace: s);
      }
    });

    on<LoadUserEvent>((event, emit) async {
      if (state is! UserLoaded) {
        AppLogger.debug("The state is not UserLoaded so returning");
        return;
      }

      final currentState = state as UserLoaded;

      if (currentState.hasReachedMax) return;

      emit(
        UserLoaded(users: usersList, isFetching: true, hasReachedMax: false),
      );
      try {
        AppLogger.debug("The current page is $currentPage");
        final newUsers = await _getUserUsecase(currentPage);
        currentPage++;
        AppLogger.debug(
          "The Previous user are as follow: ${currentState.users}",
        );
        AppLogger.debug("The newUsers data is: $newUsers");
        if (newUsers.isEmpty) {
          AppLogger.info(
            "The newUsers data is empty so returning the user: $newUsers",
          );

          emit(
            UserLoaded(
              users: usersList,
              isFetching: false,
              hasReachedMax: true,
            ),
          );
          return;
        }
        AppLogger.info("The newUsers data is returned");

        usersList = [...usersList, ...newUsers];

        emit(
          UserLoaded(users: usersList, isFetching: false, hasReachedMax: false),
        );
      } catch (e, s) {
        AppLogger.error("Error in Bloc", error: e, stackTrace: s);
      }
    }, transformer: droppable());

    on<FilterUserEvent>((event, emit) {
      try {
        emit(UserLoading());
        final filteredUsers = usersList.where((name) {
          return name.firstName.toLowerCase().contains(
            event.query.toLowerCase(),
          );
          // return name.firstName.contains(event.query);
        }).toList();
        emit(
          UserLoaded(
            users: filteredUsers,
            isFetching: false,
            hasReachedMax: false,
          ),
        );
      } catch (e, s) {
        AppLogger.error("Error", error: e, stackTrace: s);
      }
    }, transformer: droppable());
  }
}
