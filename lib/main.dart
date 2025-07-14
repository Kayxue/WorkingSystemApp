import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:working_system_app/Pages/FindWorks.dart';
import 'package:working_system_app/Pages/Login.dart';
import 'package:working_system_app/Pages/Personal.dart';
import 'package:working_system_app/Pages/Schedule.dart';
import 'package:working_system_app/Widget/bottomBar.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Find Your Gigs',
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
  }

  void clearSessionKey() {
    setState(() {
      sessionKey = '';
    });
    prefs.then((SharedPreferences preferences) {
      preferences.remove('sessionKey');
    });
  }

  @override
  void initState() {
    super.initState();
    prefs.then((SharedPreferences preferences) async {
      String? storedSessionKey = preferences.getString('sessionKey');
      if (storedSessionKey != null && storedSessionKey.isNotEmpty) {
        final response = await http.get(
          Uri.parse("http://0.0.0.0:3000/user/profile"),
          headers: {
            "platform": "mobile",
            "cookie": storedSessionKey,
          },
        );
        if (response.statusCode != 200) {
          clearSessionKey();
          return;
        }
        setState(() {
          sessionKey = storedSessionKey;
        });
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
                Findworks(),
                Login(setSessionKey: setSessionKey, updateIndex: updateIndex),
              ]
            : const <Widget>[
                Findworks(),
                Schedule(),
                Personal(),
              ])[currentIndex],
      ),
      bottomNavigationBar: Bottombar(
        currentIndex: currentIndex,
        updateIndex: updateIndex,
        sessionKey: sessionKey,
      ),
    );
  }
}
