import 'package:flutter/material.dart';

class Bottombar extends StatelessWidget{
  final int currentIndex;
  //Function to update currentIndex
  final Function(int index) updateIndex;

  const Bottombar({super.key, required this.currentIndex, required this.updateIndex});

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      onDestinationSelected: (value) => updateIndex(value),
      selectedIndex: currentIndex,
      destinations: const <NavigationDestination>[
        NavigationDestination(
          icon: Icon(Icons.calendar_month),
          label: 'Schedule',
        ),
        NavigationDestination(
          icon: Icon(Icons.search),
          label: 'Find',
        ),
        NavigationDestination(
          icon: Icon(Icons.person),
          label: 'Personal',
        ),
      ],
    );
  }
}