import 'package:apple_like_avatar_generator/apple_like_avatar_generator.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:working_system_app/Others/Utils.dart';
import 'package:working_system_app/Pages/FindWorks.dart';
import 'package:working_system_app/Pages/Login.dart';
import 'package:working_system_app/Pages/Personal.dart';
import 'package:working_system_app/Pages/Schedule.dart';
import 'package:working_system_app/Widget/BottomBar.dart';
import 'package:working_system_app/Services/FCMService.dart';
import 'package:working_system_app/Services/NotificationManager.dart';
import 'package:rhttp/rhttp.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Rhttp.init();
  await AppleLikeAvatarGenerator.init();
  await FCMService.initialize();
  await NotificationManager.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Find Your Gigs',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const ApplicationBase(),
    );
  }
}

class ApplicationBase extends StatefulWidget {
  const ApplicationBase({super.key});

  @override
  State<ApplicationBase> createState() => _ApplicationBaseState();
}

class _ApplicationBaseState extends State<ApplicationBase> {
  int currentIndex = 0;
  String sessionKey = "";
  final Future<SharedPreferences> prefs = SharedPreferences.getInstance();
  Map<String, List<String>>? cityDistrictMap;

  void updateIndex(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  void setSessionKey(String key) {
    setState(() {
      sessionKey = key;
    });
    prefs.then((SharedPreferences preferences) {
      preferences.setString('sessionKey', key);
    });
    
    NotificationManager.handleUserLogin(key);
  }

  void clearSessionKey() {
    setState(() {
      sessionKey = '';
    });
    prefs.then((SharedPreferences preferences) {
      preferences.remove('sessionKey');
    });
    
    NotificationManager.handleUserLogout();
  }

  @override
  void initState() {
    super.initState();
    prefs.then((SharedPreferences preferences) async {
      cityDistrictMap = await Utils.loadCityDistrictMap();

      String? storedSessionKey = preferences.getString('sessionKey');
      if (storedSessionKey != null && storedSessionKey.isNotEmpty) {
        final response = await Utils.client.get(
          "/user/profile",
          headers: HttpHeaders.rawMap({
            "platform": "mobile",
            "cookie": storedSessionKey,
          }),
        );
        if (response.statusCode != 200) {
          clearSessionKey();
          return;
        }
        setState(() {
          sessionKey = storedSessionKey;
        });
        
        NotificationManager.handleUserLogin(storedSessionKey);
      } else {
        clearSessionKey();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: (sessionKey.isEmpty
            ? <Widget>[
                FindWorks(
                  cityDistrictMap: cityDistrictMap,
                  sessionKey: sessionKey,
                  clearSessionKey: clearSessionKey,
                ),
                Login(setSessionKey: setSessionKey, updateIndex: updateIndex),
              ]
            : <Widget>[
                FindWorks(
                  cityDistrictMap: cityDistrictMap,
                  sessionKey: sessionKey,
                  clearSessionKey: clearSessionKey,
                ),
                Schedule(sessionKey: sessionKey),
                Personal(
                  sessionKey: sessionKey,
                  clearSessionKey: clearSessionKey,
                  updateIndex: updateIndex,
                ),
              ])[currentIndex],
      ),
      bottomNavigationBar: BottomBar(
        currentIndex: currentIndex,
        updateIndex: updateIndex,
        sessionKey: sessionKey,
      ),
    );
  }
}
