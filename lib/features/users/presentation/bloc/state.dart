import 'package:flutter_assignment/features/users/domain/entities/user.dart';

abstract class UserState {}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserLoaded extends UserState {
  final List<User> users;
  final bool isFetching;
  final bool hasReachedMax;
  UserLoaded({
    required this.users,
    required this.isFetching,
    required this.hasReachedMax,
  });
}

class UserError extends UserState {
  final String msg;

  UserError({required this.msg});
}
