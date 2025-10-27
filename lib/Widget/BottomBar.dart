import 'package:flutter/material.dart';

class BottomBar extends StatelessWidget {
  final int currentIndex;
  final String sessionKey;

  //Function to update currentIndex
  final Function(int index) updateIndex;

  const BottomBar({
    super.key,
    required this.currentIndex,
    required this.updateIndex,
    required this.sessionKey,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      onDestinationSelected: (value) => updateIndex(value),
      selectedIndex: currentIndex,
      destinations: (sessionKey.isEmpty
          ? const <NavigationDestination>[
              NavigationDestination(icon: Icon(Icons.search), label: 'Find'),
              NavigationDestination(icon: Icon(Icons.login), label: 'Login'),
            ]
          : const <NavigationDestination>[
              NavigationDestination(icon: Icon(Icons.search), label: 'Find'),
              NavigationDestination(
                icon: Icon(Icons.calendar_month),
                label: 'Schedule',
              ),
              NavigationDestination(
                icon: Icon(Icons.notifications),
                label: 'Notifications',
              ),
              NavigationDestination(
                icon: Icon(Icons.person),
                label: 'Personal',
              ),
            ]),
    );
  }
}
