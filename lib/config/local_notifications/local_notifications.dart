
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

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
      // onDidReceiveBackgroundNotificationResponse: onDidReceiveBackgroundNotificationResponse
    );
  }
}