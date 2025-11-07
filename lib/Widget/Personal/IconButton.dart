import 'package:flutter/material.dart';

class ButtonWithIcon extends StatelessWidget {
  final Color iconColor;
  final IconData icon;
  final String text;
  final Function() onPressed;

  const ButtonWithIcon({
    super.key,
    required this.iconColor,
    required this.icon,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 30),
          SizedBox(height: 8),
          SizedBox(
            width: 65,
            child: Text(
              text,
              style: TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
              softWrap: true,
              overflow: TextOverflow.visible,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}
