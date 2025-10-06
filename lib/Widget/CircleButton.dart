import 'package:flutter/material.dart';

class CircleButton extends StatelessWidget {
  final Color iconColor;
  final IconData icon;
  final String text;
  final Function() onPressed;

  const CircleButton({
    super.key,
    required this.iconColor,
    required this.icon,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon, color: iconColor),
          iconSize: 30,
          onPressed: onPressed,
        ),
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
    );
  }
}
