import 'package:flutter/material.dart';
import 'package:instgram/utils/colors.dart';

class CallButton extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  final Color color;
  const CallButton(
      {super.key,
      required this.onTap,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(12),
      ),
      onPressed: onTap,
      child: Icon(
        icon,
        color: primaryColor,
        size: 32,
      ),
    );
  }
}
