import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;

class ButtonWithIcon extends StatelessWidget {
  final Color iconColor;
  final IconData icon;
  final String text;
  final bool withBadge;
  final int badgeNumber;
  final Function() onPressed;

  const ButtonWithIcon({
    super.key,
    required this.iconColor,
    required this.icon,
    required this.text,
    required this.onPressed,
    required this.withBadge,
    required this.badgeNumber,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Column(
        children: [
          withBadge
              ? badges.Badge(
                  badgeStyle: const badges.BadgeStyle(badgeColor: Colors.blue),
                  badgeContent: badgeNumber > 99
                      ? const Text('99+',
                          style: TextStyle(color: Colors.white, fontSize: 8))
                      : Text(badgeNumber.toString(),
                          style: const TextStyle(color: Colors.white, fontSize: 10)),
                  child: Icon(icon, color: iconColor, size: 30)
                )
              : Icon(icon, color: iconColor, size: 30),
          const SizedBox(height: 8),
          SizedBox(
            width: 65,
            child: Text(
              text,
              style: const TextStyle(fontSize: 12),
              textAlign: .center,
              softWrap: true,
              overflow: .visible,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}
