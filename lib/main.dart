import 'package:flutter/material.dart';
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
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int currentIndex = 0;

  void updateIndex(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const <Widget>[Schedule(), Findworks(), Personal()][currentIndex],
      bottomNavigationBar: Bottombar(
        currentIndex: currentIndex,
        updateIndex: updateIndex,
      ),
    );
  }
}
