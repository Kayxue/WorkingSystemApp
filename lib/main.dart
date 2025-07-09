import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:working_system_app/Pages/FindWorks.dart';
import 'package:working_system_app/Pages/Personal.dart';
import 'package:working_system_app/Pages/Schedule.dart';
import 'package:working_system_app/Widget/bottomBar.dart';

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
    prefs.then((SharedPreferences preferences) {
      setState(() {
        sessionKey = preferences.getString('sessionKey') ?? '';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const <Widget>[Findworks(), Schedule(), Personal()][currentIndex],
      bottomNavigationBar: Bottombar(
        currentIndex: currentIndex,
        updateIndex: updateIndex,
      ),
    );
  }
}
