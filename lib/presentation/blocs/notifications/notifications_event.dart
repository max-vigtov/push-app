part of 'notifications_bloc.dart';

sealed class NotificationsEvent {
  const NotificationsEvent();
}

class NotificationsStatusChanged extends NotificationsEvent{
  final AuthorizationStatus status;
  NotificationsStatusChanged(this.status);
}