import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:working_system_app/Others/utils.dart';
import 'package:working_system_app/firebase_options.dart';

class FCMService {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      return;
    }

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (e) {
      Utils.logger.e('Firebase 初始化錯誤: $e');
    }

    await _requestPermission();
    await _initializeLocalNotifications();
    _setupForegroundMessageHandler();
    FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);
    _setupNotificationClickHandler();
  }

  /// 請求通知權限
  static Future<void> _requestPermission() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    Utils.logger.i('通知權限狀態: ${settings.authorizationStatus}');
  }

  /// 初始化本地通知
  static Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosInitializationSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: androidInitializationSettings,
          iOS: iosInitializationSettings,
        );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
  }

  /// 獲取 FCM Token
  static Future<String?> getFCMToken() async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      return null;
    }

    try {
      String? token = await _firebaseMessaging.getToken();
      Utils.logger.i('FCM Token: $token');
      return token;
    } catch (e) {
      Utils.logger.e('獲取 FCM Token 錯誤: $e');
      return null;
    }
  }

  /// 設定前景訊息處理
  static void _setupForegroundMessageHandler() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      Utils.logger.i('收到前景訊息: ${message.notification?.title}');

      _showLocalNotification(message);
    });
  }

  /// 顯示本地通知
  static Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          'default_channel',
          '預設通知',
          channelDescription: '應用程式的預設通知頻道',
          importance: .max,
          priority: .high,
          ticker: 'ticker',
        );

    const DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
    );

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? '新訊息',
      message.notification?.body ?? '',
      notificationDetails,
      payload: message.data.toString(),
    );
  }

  /// 設定點擊通知處理
  static void _setupNotificationClickHandler() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      Utils.logger.i('點擊通知開啟應用程式: ${message.notification?.title}');
      _handleNotificationClick(message.data);
    });

    // 處理應用程式終止時點擊通知
    FirebaseMessaging.instance.getInitialMessage().then((
      RemoteMessage? message,
    ) {
      if (message != null) {
        Utils.logger.i('從終止狀態點擊通知開啟應用程式: ${message.notification?.title}');
        _handleNotificationClick(message.data);
      }
    });
  }

  /// 處理通知點擊事件
  static void _handleNotificationClick(Map<String, dynamic> data) {
    Utils.logger.d('處理通知點擊，資料: $data');
  }

  /// 本地通知點擊處理
  static void _onNotificationTap(NotificationResponse notificationResponse) {
    Utils.logger.d('點擊本地通知: ${notificationResponse.payload}');
  }

  /// 訂閱主題
  static Future<void> subscribeToTopic(String topic) async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      return;
    }

    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      Utils.logger.i('成功訂閱主題: $topic');
    } catch (e) {
      Utils.logger.e('訂閱主題錯誤: $e');
    }
  }

  /// 取消訂閱主題
  static Future<void> unsubscribeFromTopic(String topic) async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      return;
    }

    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      Utils.logger.i('成功取消訂閱主題: $topic');
    } catch (e) {
      Utils.logger.e('取消訂閱主題錯誤: $e');
    }
  }

  /// Token 更新監聽
  static void onTokenRefresh(Function(String) callback) {
    if (!Platform.isAndroid && !Platform.isIOS) {
      return;
    }

    _firebaseMessaging.onTokenRefresh.listen(callback);
  }
}

/// 背景訊息處理器
@pragma('vm:entry-point')
Future<void> _backgroundMessageHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform  );

  Utils.logger.i('收到背景訊息: ${message.notification?.title}');

  // 注意：不要在背景處理器中顯示 UI
}
