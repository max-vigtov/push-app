import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:push_app/domain/entity/push_message.dart';
import 'package:push_app/firebase_options.dart';

part 'notifications_event.dart';
part 'notifications_state.dart';


Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");
}

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  
  int pushNumberId = 0;

  final Future<void> Function()? requestLocalNotificationsPermissions;

  final void Function({ required int id, String? title, String? body, String? data, })? showLocalNotification;

   NotificationsBloc({
     this.showLocalNotification,
     this.requestLocalNotificationsPermissions
    }) : super(const NotificationsState()) {

    on<NotificationsStatusChanged>( _notificationsStatusChanged );

    on<NotificationReceived>( _onPushMessageReceived );

    // VERIFY NOTIFICATIONS STATUS
    _initialStatusCheck();

    // NOTIFICATIONS LISTENER TO FOREGROUND
    _onForegroundMessage();
  }

  static Future<void> initializerFCM() async{
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  void _notificationsStatusChanged(NotificationsStatusChanged event, Emitter<NotificationsState> emit){
    emit(
      state.copyWith(
        status: event.status
      )
    );
    _getFCMToken();
  }

  void _onPushMessageReceived(NotificationReceived event, Emitter<NotificationsState> emit){
    emit(
      state.copyWith(
        notifications: [event.pushMessage, ... state.notifications]
      )
    );
    _getFCMToken();
  }

  void _initialStatusCheck() async{
    final settings = await messaging.getNotificationSettings();
    add(NotificationsStatusChanged(settings.authorizationStatus));
  }

  void _getFCMToken() async{

    if(state.status != AuthorizationStatus.authorized) return;

    final token = await messaging.getToken();
    print(token);
  }  

  void handleRemoteMessage ( RemoteMessage message ){
    if (message.notification == null) return;

    final notification = PushMessage(
      messageId: message.messageId
        ?.replaceAll(':', '').replaceAll('%', '')
        ?? '', 
      title: message.notification!.title ?? '', 
      body: message.notification!.body ?? '', 
      sentDate: message.sentTime ?? DateTime.now(),
      data: message.data,
      imageUrl: Platform.isAndroid
      ? message.notification!.android?.imageUrl
      : message.notification!.apple?.imageUrl,
    );

  if( showLocalNotification != null ){

    showLocalNotification!(
      id: ++pushNumberId,
      body: notification.body,
      data: notification.messageId,
      title: notification.title,
    );
  }
    add(NotificationReceived(notification));

  }

  void _onForegroundMessage(){
    FirebaseMessaging.onMessage.listen(handleRemoteMessage);
  }

  void requestPermissions() async{
   NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
   );
  //Solicitar acceso a las local notification

  if(requestLocalNotificationsPermissions != null){
    await requestLocalNotificationsPermissions!();
  }

  add(NotificationsStatusChanged(settings.authorizationStatus));
  }  

  PushMessage? getMessageById ( String pushMessageId){
    final exist = state.notifications.any((element) => element.messageId == pushMessageId);
    if (!exist ) return null;
    
    return state.notifications.firstWhere((element) => element.messageId == pushMessageId);
  }
}
