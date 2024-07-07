import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:push_app/config/router/app_roputer.dart';

class LocalNotifications {

  static Future<void> requestPermissionLocalNotifications() async{

    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static Future<void> initializationLocalNotifications() async{
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const initializationSettingsAndroid = AndroidInitializationSettings('app_icon');

    //TODO: iOS Configuration

    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid
      //TODO: iOS Configuration
      //iOS: 

    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
       onDidReceiveNotificationResponse: onDidReceiveNotificationResponse
    );
  }

  static void showLocalNotification({
    required int id,
    String? title,
    String? body,
    String? data,
  }) {
    const androidDetails = AndroidNotificationDetails(
      'chanelId', 
      'channelName',
      playSound: true,
      sound: RawResourceAndroidNotificationSound('notification'),
      importance: Importance.max,
      priority: Priority.high
    );

    const notificationDetails = NotificationDetails(
     android: androidDetails
    );

    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.show(id, title, body, notificationDetails, payload: data);
  }

  static void onDidReceiveNotificationResponse(NotificationResponse response){
    appRouter.push('/push-detail/${response.payload}');
  }

}