import 'package:flutter_assignment/features/users/domain/entities/user.dart';
import 'package:flutter_assignment/features/users/presentation/form_inputs/search_input.dart';

abstract class UserState {}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserLoaded extends UserState {
  final List<User> users;
  final bool isFetching;
  final bool hasReachedMax;
  final SearchInput searchInput;
  UserLoaded({
    required this.users,
    required this.isFetching,
    required this.hasReachedMax,
    this.searchInput = const SearchInput.pure(),
  });
}

class UserError extends UserState {
  final String msg;

  UserError({required this.msg});
}
