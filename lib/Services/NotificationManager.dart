import 'package:flutter/foundation.dart';
import 'package:rhttp/rhttp.dart';
import 'dart:io';
import 'package:working_system_app/Services/FCMService.dart';
import 'package:working_system_app/Others/Utils.dart';

/// 通知管理器
class NotificationManager {
  static bool _isInitialized = false;
  static String? _currentFCMToken;
  static String? _currentSessionKey;
  
  /// 初始化通知管理器
  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    if (!Platform.isAndroid && !Platform.isIOS) {
      _isInitialized = true;
      return;
    }
    
    try {
      _currentFCMToken = await FCMService.getFCMToken();
      FCMService.onTokenRefresh((String newToken) {
        _onTokenUpdated(newToken);
      });
      
      await _subscribeToDefaultTopics();
      _isInitialized = true;
      
      if (kDebugMode) {
        print('通知管理器初始化完成');
      }
    } catch (e) {
      if (kDebugMode) {
        print('通知管理器初始化失敗: $e');
      }
    }
  }
  
  static String? getCurrentToken() {
    return _currentFCMToken;
  }
  
  static void _onTokenUpdated(String newToken) {
    if (kDebugMode) {
      print('FCM Token 已更新: $newToken');
    }
    
    _currentFCMToken = newToken;
    _sendTokenToServer(newToken);
  }
  
  static Future<void> _sendTokenToServer(String token) async {
    try {
      if (_currentSessionKey == null || _currentSessionKey!.isEmpty) {
        if (kDebugMode) {
          print('使用者未登入，跳過 FCM Token 註冊');
        }
        return;
      }
      
      String deviceType = _getDeviceType();
      
      Map<String, String> requestBody = {
        "token": token,
        "deviceType": deviceType,
      };
      
      Map<String, String> headers = {
        "platform": "mobile",
        "Content-Type": "application/json",
        "cookie": _currentSessionKey!,
      };
      
      if (kDebugMode) {
        print('發送 FCM Token 到伺服器');
      }
      
      final response = await Utils.client.post(
        "/fcm/register",
        headers: HttpHeaders.rawMap(headers),
        body: HttpBody.json(requestBody),
      );
      
      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('FCM Token 註冊成功');
        }
      } else {
        if (kDebugMode) {
          print('FCM Token 註冊失敗，狀態碼: ${response.statusCode}');
          print('回應內容: ${response.body}');
          
          if (response.statusCode == 401) {
            print('Session 可能已過期，清除本地 sessionKey');
            _currentSessionKey = null;
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('發送 Token 到伺服器失敗: $e');
      }
    }
  }
  
  /// 檢測裝置類型
  static String _getDeviceType() {
    if (kIsWeb) {
      return 'web';
    } else if (Platform.isAndroid) {
      return 'android';
    } else if (Platform.isIOS) {
      return 'ios';
    } else {
      return 'other';
    }
  }
  
  /// 訂閱預設主題
  static Future<void> _subscribeToDefaultTopics() async {
    await FCMService.subscribeToTopic('general_notifications');
    
    if (kDebugMode) {
      print('已訂閱一般通知主題');
    }
  }
  
  /// 根據使用者登入狀態管理訂閱
  static Future<void> handleUserLogin(String sessionKey) async {
    _currentSessionKey = sessionKey;
    
    if (Platform.isAndroid || Platform.isIOS) {
      if (_currentFCMToken != null) {
        await _sendTokenToServer(_currentFCMToken!);
      }
    }
  }
  
  /// 處理使用者登出
  static Future<void> handleUserLogout() async {
    _currentSessionKey = null;
  }
  
}
