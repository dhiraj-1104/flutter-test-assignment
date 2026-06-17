abstract class UserEvent {}

class GetUserEvent extends UserEvent {}

class LoadUserEvent extends UserEvent {}

class FilterUserEvent extends UserEvent {
  final String query;

  FilterUserEvent({required this.query});
}
